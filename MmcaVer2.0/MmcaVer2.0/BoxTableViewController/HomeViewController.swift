import UIKit

class HomeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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

