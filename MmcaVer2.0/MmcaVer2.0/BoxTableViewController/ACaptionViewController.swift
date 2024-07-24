import UIKit

// ACaptionViewController 클래스는 사진을 선택하거나 촬영하여 편집할 수 있는 기능을 제공합니다.
// UIImagePickerControllerDelegate와 UINavigationControllerDelegate를 채택하여 이미지 선택기와 내비게이션을 관리합니다.
class ACaptionViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // 이미지 선택기를 초기화합니다.
    let imagePicker = UIImagePickerController()
    
    // viewDidLoad 메서드는 뷰가 로드될 때 호출되며 초기 설정을 수행합니다.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 화면 제목을 "사진 선택"으로 설정합니다.
        self.title = "사진 선택"
        
        // 이미지 선택기의 대리자를 현재 뷰 컨트롤러로 설정합니다.
        imagePicker.delegate = self
        // 사용자 정의 내비게이션 버튼을 설정합니다.
        setupCustomNavigationButton()
        
        // 사용자 인터페이스 버튼을 설정합니다.
        setupButtons()
    }
    
    // 사진을 업로드하는 버튼을 클릭했을 때 호출됩니다.
    @IBAction func uploadPhoto(_ sender: UIButton) {
        // 사진 앨범에서 이미지를 선택하도록 소스 유형을 설정합니다.
        imagePicker.sourceType = .photoLibrary
        // 이미지 선택기를 화면에 표시합니다.
        present(imagePicker, animated: true, completion: nil)
    }
    
    // 사진을 촬영하는 버튼을 클릭했을 때 호출됩니다.
    @IBAction func takePhoto(_ sender: UIButton) {
        // 카메라 사용이 가능한지 확인합니다.
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            // 카메라에서 이미지를 선택하도록 소스 유형을 설정합니다.
            imagePicker.sourceType = .camera
            // 이미지 선택기를 화면에 표시합니다.
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    // 이미지 선택기가 이미지를 선택한 후 호출됩니다.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // 이미지 선택기를 닫습니다.
        picker.dismiss(animated: true, completion: nil)
        // 선택한 이미지가 유효한지 확인합니다.
        guard let image = info[.originalImage] as? UIImage else { return }
        
        // 메인 스토리보드를 로드합니다.
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        // ACameraViewController를 인스턴스화합니다.
        if let photoEditingVC = storyboard.instantiateViewController(withIdentifier: "ACameraViewController") as? ACameraViewController {
            // 선택한 이미지를 ACameraViewController에 전달합니다.
            photoEditingVC.selectedImage = image
            // ACameraViewController로 이동합니다.
            self.navigationController?.pushViewController(photoEditingVC, animated: true)
        }
    }
    
    // 사용자 정의 내비게이션 버튼을 설정하는 메서드입니다.
    func setupCustomNavigationButton() {
        // 뒤로 가기 버튼을 생성합니다.
        let homeChevron = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(goToHome))
        // 홈 버튼을 생성합니다.
        let homeButton = createCustomButton(title: " 홈 ", image: nil, action: #selector(goToHome))
        let customHomeButton = UIBarButtonItem(customView: homeButton)
        
        // 내비게이션 아이템의 왼쪽 버튼으로 설정합니다.
        self.navigationItem.leftBarButtonItems = [homeChevron, customHomeButton]
    }
    
    // 사용자 정의 버튼을 생성하는 메서드입니다.
    func createCustomButton(title: String, image: String?, action: Selector) -> UIButton {
        // 버튼의 기본 설정을 구성합니다.
        var config = UIButton.Configuration.plain()
        config.title = title
        config.baseForegroundColor = .black
        config.background.backgroundColor = .white
        config.background.strokeColor = .black
        config.background.strokeWidth = 1
        config.background.cornerRadius = 5
        config.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 7, bottom: 5, trailing: 7)
        
        // 버튼을 생성하고 설정을 적용합니다.
        let button = UIButton(configuration: config, primaryAction: nil)
        // 이미지가 있는 경우 설정합니다.
        if let imageName = image {
            button.setImage(UIImage(systemName: imageName), for: .normal)
            button.imageView?.contentMode = .scaleAspectFit
        }
        // 버튼에 액션을 추가합니다.
        button.addTarget(self, action: action, for: .touchUpInside)
        
        return button
    }
    
    // 홈으로 이동하는 메서드입니다.
    @objc func goToHome() {
        // 내비게이션 스택의 루트 뷰 컨트롤러로 돌아갑니다.
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    // 사용자 인터페이스 버튼을 설정하는 메서드입니다.
    func setupButtons() {
        // 사진 가져오기 버튼을 생성합니다.
        let uploadPhotoButton = createCustomButton(title: "사진 가져오기", image: "photo.on.rectangle", action: #selector(uploadPhoto(_:)))
        uploadPhotoButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(uploadPhotoButton)
        
        // 사진 촬영하기 버튼을 생성합니다.
        let takePhotoButton = createCustomButton(title: "사진 촬영하기", image: "camera", action: #selector(takePhoto(_:)))
        takePhotoButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(takePhotoButton)
        
        // 버튼의 레이아웃 제약 조건을 설정합니다.
        NSLayoutConstraint.activate([
            uploadPhotoButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            uploadPhotoButton.heightAnchor.constraint(equalToConstant: 150),
            uploadPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            uploadPhotoButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -80),
            
            takePhotoButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            takePhotoButton.heightAnchor.constraint(equalToConstant: 150),
            takePhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            takePhotoButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 80)
        ])
    }
}
