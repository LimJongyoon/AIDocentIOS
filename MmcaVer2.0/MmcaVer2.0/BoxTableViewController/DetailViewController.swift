import UIKit
import CoreBluetooth

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var peripheral: CBPeripheral?
    var rssiValue: NSNumber?
    
    let tableView = UITableView()
    var messages: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 배경색을 흰색으로 설정
        self.view.backgroundColor = .white

        // 네비게이션 바에 뒤로 가기 버튼 추가
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButtonTapped))
        self.navigationItem.leftBarButtonItem = backButton

        // 전달된 정보를 사용하여 뷰를 설정
        if let peripheral = peripheral, let _ = rssiValue {
            self.title = peripheral.name
            
            // 이미지 파일을 Assets에서 찾기
            var image: UIImage? = UIImage(named: peripheral.name ?? "Unknown")
            
            // 이미지가 없을 경우, 시스템의 기본 이미지 사용
            if image == nil {
                image = UIImage(named: "EmptyQuestionMark") // 빈 이미지에 적합한 이미지
            }
            
            // 이미지 메시지 추가
            if image != nil {
                messages.append("Image: \(peripheral.name ?? "Unknown")")
            }
            
            // 이름과 설명 메시지 추가
            messages.append("\(peripheral.name ?? "Unknown")")
            messages.append("작가(연도), 000x000mm, 재료  ")
            messages.append("설명입니다 설명입니다 설명입니다 설명입니다 설명입니다 설명입니다 설명입니다 설명입니다 설명입니다 설명입니다 설명입니다 설명입니다 설명입니다 설명입니다 설명입니다 설명입니다 설명입니다 설명입니다 설명입니다 설명입니다 설명입니다 설명입니다 설명입니다 설명입니다 설명입니다 설명입니다 설명입니다 설명입니다 설명입니다 설명입니다")
        }

        // 테이블 뷰 설정
        tableView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ChatCell")
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(tableView)
    }

    @objc func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
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
}
