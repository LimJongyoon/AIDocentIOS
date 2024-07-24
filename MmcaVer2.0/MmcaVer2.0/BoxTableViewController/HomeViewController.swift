import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var mediaWallButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupButtonStyle(button: infoButton, title: "내 주위 소장품", systemImageName: "info.circle")
        setupButtonStyle(button: searchButton, title: "소장품 검색", systemImageName: "magnifyingglass")
        setupButtonStyle(button: cameraButton, title: "라벨 카메라", systemImageName: "camera")
        setupButtonStyle(button: mediaWallButton, title: "미디어월 연결", systemImageName: "photo.on.rectangle")
        
        setButtonSize(button: infoButton)
        setButtonSize(button: searchButton)
        setButtonSize(button: cameraButton)
        setButtonSize(button: mediaWallButton)
    }
    
    func setupButtonStyle(button: UIButton, title: String, systemImageName: String) {
        
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.black.cgColor
        button.clipsToBounds = true
        
        button.backgroundColor = .white
        
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
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let infoVC = storyboard.instantiateViewController(withIdentifier: "InfoViewController") as? InfoViewController {
            self.navigationController?.pushViewController(infoVC, animated: true)
        }
    }
    
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let SearchVC = storyboard.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController {
            self.navigationController?.pushViewController(SearchVC, animated: true)
        }
    }
    
    @IBAction func cameraButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let cameraVC = storyboard.instantiateViewController(withIdentifier: "ACameraViewController") as? ACameraViewController {
            cameraVC.autoOpenCamera = true
            self.navigationController?.pushViewController(cameraVC, animated: true)
        }
    }
    
    @IBAction func mediaWallButtonTapped(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: "준비중입니다", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
