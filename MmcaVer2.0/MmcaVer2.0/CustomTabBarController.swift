import UIKit

class CustomTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
        // Create view controllers for each tab
        let firstVC = HomeViewController()
        let secondVC = InfoViewController()
        let thirdVC = SearchViewController()
        let fourthVC = SearchViewController()
        let fifthVC = SearchViewController()
        let sixthVC = SearchViewController()
        
        // Set tab bar items
        firstVC.tabBarItem = UITabBarItem(title: "First", image: UIImage(named: "first_icon"), tag: 0)
        secondVC.tabBarItem = UITabBarItem(title: "Second", image: UIImage(named: "second_icon"), tag: 1)
        thirdVC.tabBarItem = UITabBarItem(title: "Third", image: UIImage(named: "third_icon"), tag: 2)
        fourthVC.tabBarItem = UITabBarItem(title: "Fourth", image: UIImage(named: "fourth_icon"), tag: 3)
        fifthVC.tabBarItem = UITabBarItem(title: "Fifth", image: UIImage(named: "fifth_icon"), tag: 4)
        sixthVC.tabBarItem = UITabBarItem(title: "Sixth", image: UIImage(named: "sixth_icon"), tag: 5)
        
        // Add view controllers to the tab bar
        self.viewControllers = [firstVC, secondVC, thirdVC, fourthVC, fifthVC, sixthVC]
        
        // Customize tab bar appearance
        self.tabBar.isTranslucent = false
        self.tabBar.tintColor = .systemBlue
        self.tabBar.barTintColor = .white
    }
}
