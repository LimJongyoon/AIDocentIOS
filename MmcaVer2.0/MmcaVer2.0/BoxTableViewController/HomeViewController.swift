import UIKit

class HomeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    
    @IBAction func titleButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil) // "Main"은 해당 스토리보드의 이름입니다.
        if let initialVC = storyboard.instantiateViewController(withIdentifier: "InitialViewController") as? InitialViewController {
            // 네비게이션 컨트롤러를 사용하는 경우
            //self.navigationController?.pushViewController(initialVC, animated: true)
            // 모달로 표시하는 경우
            initialVC.modalPresentationStyle = .fullScreen
            self.present(initialVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func infoButtonTapped(_ sender: UIButton) {
        if let tabBar = tabBarController {
            tabBar.selectedIndex = 1 // InfoViewController의 인덱스는 1입니다.
        }
    }
    
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        if let tabBar = tabBarController {
            tabBar.selectedIndex = 2 // SearchViewController의 인덱스는 2입니다.
        }
    }
    
    
    
    @IBAction func cameraButtonTapped(_ sender: UIButton) {
//        if let visionViewController = UIStoryboard(name: "Cam", bundle: nil).instantiateViewController(withIdentifier: "VisionObjectRecognitionViewController") as? VisionObjectRecognitionViewController {
//            self.present(visionViewController, animated: true, completion: nil)    }
//        
    }
}

