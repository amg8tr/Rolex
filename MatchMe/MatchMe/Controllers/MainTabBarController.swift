import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
    }
    
    private func setupTabBar() {
        // Create view controllers for each tab
        let discoverVC = DiscoverViewController()
        let matchesVC = MatchesViewController()
        let profileVC = ProfileViewController()
        let chatVC = ChatViewController()
        
        // Configure tab bar items
        discoverVC.tabBarItem = UITabBarItem(title: "Discover", image: UIImage(systemName: "heart.fill"), tag: 0)
        matchesVC.tabBarItem = UITabBarItem(title: "Matches", image: UIImage(systemName: "person.2.fill"), tag: 1)
        chatVC.tabBarItem = UITabBarItem(title: "Chat", image: UIImage(systemName: "message.fill"), tag: 2)
        profileVC.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.fill"), tag: 3)
        
        // Set view controllers
        viewControllers = [
            UINavigationController(rootViewController: discoverVC),
            UINavigationController(rootViewController: matchesVC),
            UINavigationController(rootViewController: chatVC),
            UINavigationController(rootViewController: profileVC)
        ]
        
        // Configure tab bar appearance
        tabBar.tintColor = UIColor.systemPink
        tabBar.backgroundColor = UIColor.systemBackground
    }
} 