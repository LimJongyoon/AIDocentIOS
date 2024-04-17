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
    
}

