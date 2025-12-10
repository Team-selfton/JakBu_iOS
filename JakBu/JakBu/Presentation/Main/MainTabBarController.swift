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
        // Configure tab bar appearance
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .jakbuBackgroundBottom

        // Configure normal state
        let normalAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.jakbuTextQuaternary,
            .font: UIFont.systemFont(ofSize: 10, weight: .medium)
        ]
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttributes
        appearance.stackedLayoutAppearance.normal.iconColor = .jakbuTextQuaternary

        // Configure selected state
        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.jakbuSelectedStart,
            .font: UIFont.systemFont(ofSize: 10, weight: .semibold)
        ]
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttributes
        appearance.stackedLayoutAppearance.selected.iconColor = .jakbuSelectedStart

        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }

        tabBar.tintColor = .jakbuSelectedStart
        tabBar.unselectedItemTintColor = .jakbuTextQuaternary
    }

    private func setupTabs() {
        let homeVC = HomeViewController()
        let homeNav = UINavigationController(rootViewController: homeVC)
        homeNav.tabBarItem = UITabBarItem(title: "메인", image: UIImage(systemName: "house.fill"), tag: 0)

        let calendarVC = CalendarViewController()
        let calendarNav = UINavigationController(rootViewController: calendarVC)
        calendarNav.tabBarItem = UITabBarItem(title: "캘린더", image: UIImage(systemName: "calendar"), tag: 1)

        viewControllers = [homeNav, calendarNav]
    }
}
