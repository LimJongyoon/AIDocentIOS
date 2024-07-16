import UIKit
import CoreBluetooth
import AVFoundation // 음성 합성을 위한 프레임워크

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AVSpeechSynthesizerDelegate {
    var peripheral: CBPeripheral?
    var rssiValue: NSNumber?
    var deviceInfo: [String: (title: String, artist: String, size: String, material: String, description: String)] = [:]
    var selectedDeviceInfo: (title: String, artist: String, size: String, material: String, description: String)? // 선택된 디바이스 정보를 저장할 변수
    
    let tableView = UITableView()
    var messages: [String] = []
    var chatButton: UIButton! // 채팅 버튼을 선언합니다.
    
    // 음성 합성을 위한 변수 선언
    var speechSynthesizer = AVSpeechSynthesizer()
    var isSpeaking = false // 현재 음성 재생 여부를 저장하는 변수
    var lastSpokenMessage: String? // 마지막으로 읽었던 메시지를 저장하는 변수
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 배경색을 흰색으로 설정
        self.view.backgroundColor = .white
        
        setupCustomNavigationButtons()
        
        //        // 네비게이션 바에 뒤로 가기 버튼 추가
        //        let backButton = UIBarButtonItem(title: "내 주위...", style: .plain, target: self, action: #selector(backButtonTapped))
        //        self.navigationItem.leftBarButtonItem = backButton
        
        // 전달된 정보를 사용하여 뷰를 설정
        if let peripheral = peripheral, let _ = rssiValue {
            // 디바이스 정보 설정
            if let info = deviceInfo[peripheral.name ?? ""] {
                self.title = info.title
                
                // 이미지 파일을 Assets에서 찾기
                let imageName = peripheral.name ?? "Unknown"
                var image: UIImage? = UIImage(named: imageName)
                
                // 이미지가 없을 경우, 시스템의 기본 이미지 사용
                if image == nil {
                    image = UIImage(named: "EmptyQuestionMark") // 빈 이미지에 적합한 이미지
                }
                
                // 이미지 메시지 추가
                if image != nil {
                    messages.append("Image: \(imageName)")
                }
                
                // 이름과 설명 메시지 추가
                let artworkInfo = info.title
                let artworkDetails = "\(info.artist), \(info.size), \(info.material)"
                let artworkDescription = info.description
                //messages.append(artworkInfo) // 제목타이틀 있으니까ㅜ지워
                messages.append(artworkDetails)
                messages.append(artworkDescription)
                
                // 음성으로 읽기 시작
                speakText("\(artworkInfo)\n\(artworkDetails)\n\(artworkDescription)")
            }
        } else if let info = selectedDeviceInfo {
            self.title = info.title
            
            // 이미지 파일을 Assets에서 찾기
            let imageName = info.title
            var image: UIImage? = UIImage(named: imageName)
            
            // 이미지가 없을 경우, 시스템의 기본 이미지 사용
            if image == nil {
                image = UIImage(named: "EmptyQuestionMark") // 빈 이미지에 적합한 이미지
            }
            
            // 이미지 메시지 추가
            if image != nil {
                messages.append("Image: \(imageName)")
            }
            
            // 이름과 설명 메시지 추가
            let artworkInfo = info.title
            let artworkDetails = "\(info.artist), \(info.size), \(info.material)"
            let artworkDescription = info.description
            messages.append(artworkInfo)
            messages.append(artworkDetails)
            messages.append(artworkDescription)
            
            // 음성으로 읽기 시작
            speakText("\(artworkInfo)\n\(artworkDetails)\n\(artworkDescription)")
        }
        
        // 테이블 뷰 설정
        tableView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ChatCell")
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(tableView)
        
        // "AI도슨트와 채팅하기" 버튼 설정
        setupChatButton()
        
        // 터치 이벤트 감지 설정
        setupTapGesture()
    }
    
    func setupCustomNavigationButtons() {
        // 홈 버튼 설정
        let homeButton = createCustomButton(title: "홈", image: "chevron.left", action: #selector(goToHome))
        let customHomeButton = UIBarButtonItem(customView: homeButton)
        
        // 내 주위 소장품 버튼 설정
        let infoButtonTitle = navigationController?.viewControllers.dropLast().last?.title ?? ""
        let infoButton = createCustomButton(title: "/ \(infoButtonTitle)", image: nil, action: #selector(goToInfo))
        let customInfoButton = UIBarButtonItem(customView: infoButton)
        
        self.navigationItem.leftBarButtonItems = [customHomeButton, customInfoButton]
    }
    
    
    func createCustomButton(title: String, image: String?, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        if let imageName = image {
            button.setImage(UIImage(systemName: imageName), for: .normal)
        }
        button.setTitle(title, for: .normal)
        button.sizeToFit()
        button.addTarget(self, action: action, for: .touchUpInside)
        
        // 폰트 종류와 크기 설정
        button.titleLabel?.font = UIFont(name: "San Francisco", size: 17) // 폰트 종류와 크기 설정
        button.setTitleColor(.black, for: .normal) // 버튼 텍스트 색상 설정
        
        return button
    }
    
    @objc func goToHome() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func goToInfo() {
        if let viewControllers = self.navigationController?.viewControllers {
            for vc in viewControllers {
                if vc is InfoViewController {
                    self.navigationController?.popToViewController(vc, animated: true)
                    return
                }
            }
        }
    }
    
    // "AI도슨트와 채팅하기" 버튼 설정 메서드입니다.
    func setupChatButton() {
        chatButton = UIButton(type: .system) // 버튼 초기화
        chatButton.setTitle("AI도슨트와 채팅하기", for: .normal) // 버튼 타이틀 설정
        chatButton.addTarget(self, action: #selector(chatButtonTapped), for: .touchUpInside) // 버튼 액션 설정
        chatButton.translatesAutoresizingMaskIntoConstraints = false // 오토 레이아웃 사용
        
        self.view.addSubview(chatButton) // 버튼을 뷰에 추가
        
        // 제약 조건 설정
        NSLayoutConstraint.activate([
            chatButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor), // 버튼을 화면 중앙에 배치
            chatButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -20), // 버튼을 화면 하단에 배치
            chatButton.widthAnchor.constraint(equalToConstant: 200), // 버튼 너비 설정
            chatButton.heightAnchor.constraint(equalToConstant: 50) // 버튼 높이 설정
        ])
    }
    
    // 터치 이벤트 감지 설정 메서드입니다.
    func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
    }
    
    // 터치 이벤트 핸들러
    @objc func handleTapGesture() {
        stopSpeaking() // 터치 이벤트가 발생하면 음성을 중지
    }
    
    
    @objc func backButtonTapped() {
        stopSpeaking() // 뒤로 가기 버튼을 누르면 음성을 중지
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func previousButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func chatButtonTapped() {
        stopSpeaking() // ChatViewController로 전환하기 전에 음성을 중지
        // ChatViewController로 전환하는 코드입니다.
        let chatVC = ChatViewController()
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
    
    // UITableViewDataSource 메소드
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath)
        
        let message = messages[indexPath.row]
        
        // 메시지가 이미지일 경우
        if message.starts(with: "Image: ") {
            let imageName = message.replacingOccurrences(of: "Image: ", with: "")
            if let image = UIImage(named: imageName) {
                let imageView = UIImageView(image: image)
                imageView.frame = CGRect(x: 10, y: 10, width: cell.contentView.bounds.width - 20, height: 200)
                imageView.contentMode = .scaleAspectFit
                cell.contentView.addSubview(imageView)
            }
        } else {
            // 텍스트 메시지일 경우
            cell.textLabel?.text = message
            cell.textLabel?.numberOfLines = 0 // 여러 줄 텍스트를 표시할 수 있도록 설정
        }
        
        return cell
    }
    
    // UITableViewDelegate 메소드
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let message = messages[indexPath.row]
        if message.starts(with: "Image: ") {
            return 220 // 이미지 셀의 높이 설정
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let message = messages[indexPath.row]
        if message.starts(with: "Image: ") {
            return 220 // 이미지 셀의 예상 높이 설정
        }
        return 44
    }
    
    // 텍스트를 음성으로 읽어주는 메서드입니다.
    func speakText(_ text: String) {
        if isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate) // 현재 음성을 즉시 멈춥니다.
        }
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "ko-KR") // 한국어 음성으로 설정합니다.
        speechSynthesizer.speak(utterance)
        isSpeaking = true // 음성 재생 여부를 true로 설정합니다.
    }
    
    // 음성을 중지하는 메서드입니다.
    func stopSpeaking() {
        if isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate) // 현재 음성을 즉시 멈춥니다.
            isSpeaking = false
        }
    }
    
    // AVSpeechSynthesizerDelegate 메서드
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        isSpeaking = false // 음성 합성이 완료되면 isSpeaking을 false로 설정합니다.
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        isSpeaking = false // 음성 합성이 취소되면 isSpeaking을 false로 설정합니다.
    }
}
