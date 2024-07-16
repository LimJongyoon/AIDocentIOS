import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var mediaWallButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 버튼 스타일 설정
        //흑백
//        setupButtonStyle(button: infoButton, gradientColors: [UIColor.black.cgColor, UIColor.systemGray2.cgColor], systemImageName: "info.circle", title: "내 주위 소장품")
//        setupButtonStyle(button: searchButton, gradientColors: [UIColor.black.cgColor, UIColor.systemGray2.cgColor], systemImageName: "magnifyingglass", title: "소장품 검색")
//        setupButtonStyle(button: cameraButton, gradientColors: [UIColor.systemGray2.cgColor, UIColor.black.cgColor], systemImageName: "camera", title: "라벨 카메라")
//        setupButtonStyle(button: mediaWallButton, gradientColors: [UIColor.systemGray2.cgColor, UIColor.black.cgColor], systemImageName: "photo.on.rectangle", title: "미디어월 연결")
        
        //칼라풀 ㅋㅋ
//        setupButtonStyle(button: infoButton, gradientColors: [UIColor.systemGreen.withAlphaComponent(0.7).cgColor, UIColor.systemYellow.withAlphaComponent(0.7).cgColor], systemImageName: "info.circle", title: "내 주위 소장품")
//        setupButtonStyle(button: searchButton, gradientColors: [UIColor.systemOrange.withAlphaComponent(0.7).cgColor, UIColor.systemPink.withAlphaComponent(0.7).cgColor], systemImageName: "magnifyingglass", title: "소장품 검색")
//        setupButtonStyle(button: cameraButton, gradientColors: [UIColor.systemRed.withAlphaComponent(0.7).cgColor, UIColor.systemPurple.withAlphaComponent(0.7).cgColor], systemImageName: "camera", title: "라벨 카메라")
//        setupButtonStyle(button: mediaWallButton, gradientColors: [UIColor.systemBlue.withAlphaComponent(0.7).cgColor, UIColor.systemTeal.withAlphaComponent(0.7).cgColor], systemImageName: "photo.on.rectangle", title: "미디어월 연결")

        setupButtonStyle(button: infoButton, title: "내 주위 소장품", systemImageName: "info.circle")
        setupButtonStyle(button: searchButton, title: "소장품 검색", systemImageName: "magnifyingglass")
        setupButtonStyle(button: cameraButton, title: "라벨 카메라", systemImageName: "camera")
        setupButtonStyle(button: mediaWallButton, title: "미디어월 연결", systemImageName: "photo.on.rectangle")
        
        // 버튼 크기 설정
        setButtonSize(button: infoButton)
        setButtonSize(button: searchButton)
        setButtonSize(button: cameraButton)
        setButtonSize(button: mediaWallButton)
    }
    
//    func setupButtonStyle(button: UIButton, gradientColors: [CGColor], systemImageName: String, title: String) {
    func setupButtonStyle(button: UIButton, title: String, systemImageName: String) {
        
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.black.cgColor
        button.clipsToBounds = true
        
        // 배경 설정
        button.backgroundColor = .white
        
//        // 그라데이션 배경 설정
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.colors = gradientColors
//        if title == "소장품 검색" || title == "라벨 카메라" {
//            gradientLayer.startPoint = CGPoint(x: 1, y: 0)
//            gradientLayer.endPoint = CGPoint(x: 0, y: 1)
//        } else {
//            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
//            gradientLayer.endPoint = CGPoint(x: 1, y: 1)
//        }
//        gradientLayer.frame = button.bounds
//        button.layer.insertSublayer(gradientLayer, at: 0)
        
        // UIButtonConfiguration을 사용하여 이미지와 텍스트 배치
        var config = UIButton.Configuration.plain()
        config.title = title
        config.image = UIImage(systemName: systemImageName)
        config.imagePlacement = .top
        config.imagePadding = 8
        config.titleAlignment = .center
        button.configuration = config
    }
    
    func setButtonSize(button: UIButton) {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 100).isActive = true
        button.widthAnchor.constraint(equalToConstant: 100).isActive = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateGradientFrame(button: infoButton)
        updateGradientFrame(button: searchButton)
        updateGradientFrame(button: cameraButton)
        updateGradientFrame(button: mediaWallButton)
    }
    
    func updateGradientFrame(button: UIButton) {
        if let gradientLayer = button.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = button.bounds
        }
    }
    
    @IBAction func titleButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let initialVC = storyboard.instantiateViewController(withIdentifier: "InitialViewController") as? InitialViewController {
            initialVC.modalPresentationStyle = .fullScreen
            self.present(initialVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func infoButtonTapped(_ sender: UIButton) {
//        if let tabBar = tabBarController { //이거로 하면 네비게이션 이동이아니라 뒤로가기가 안생김 ㅋ
//            tabBar.selectedIndex = 1
//        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let infoVC = storyboard.instantiateViewController(withIdentifier: "InfoViewController") as? InfoViewController {
            self.navigationController?.pushViewController(infoVC, animated: true)
        }
    }
    
    @IBAction func searchButtonTapped(_ sender: UIButton) {
//        if let tabBar = tabBarController {
//            tabBar.selectedIndex = 2
//        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let SearchVC = storyboard.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController {
            self.navigationController?.pushViewController(SearchVC, animated: true)
        }
    }
    
    @IBAction func cameraButtonTapped(_ sender: UIButton) {
//        if let tabBar = tabBarController {
//            tabBar.selectedIndex = 3
//        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let CameraVC = storyboard.instantiateViewController(withIdentifier: "CameraViewController") as? CameraViewController {
            self.navigationController?.pushViewController(CameraVC, animated: true)
        }
    }
    
    @IBAction func mediaWallButtonTapped(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: "준비중입니다", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

}
