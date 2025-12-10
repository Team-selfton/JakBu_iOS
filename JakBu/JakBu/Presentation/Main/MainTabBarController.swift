import UIKit

class MainTabBarController: UITabBarController {

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTabs()
    }

    // MARK: - Setup

    private func setupUI() {
        tabBar.backgroundColor = .systemBackground
        tabBar.tintColor = .systemBlue
        tabBar.unselectedItemTintColor = .systemGray
    }

    private func setupTabs() {
        let homeVC = HomeViewController()
        let homeNav = UINavigationController(rootViewController: homeVC)
        homeNav.tabBarItem = UITabBarItem(title: "홈", image: UIImage(systemName: "house"), tag: 0)

        let calendarVC = CalendarViewController()
        let calendarNav = UINavigationController(rootViewController: calendarVC)
        calendarNav.tabBarItem = UITabBarItem(title: "캘린더", image: UIImage(systemName: "calendar"), tag: 1)

        viewControllers = [homeNav, calendarNav]
    }
}
