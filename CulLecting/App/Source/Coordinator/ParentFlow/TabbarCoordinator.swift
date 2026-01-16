//
//  TabbarCoordinator.swift
//  CulLecting
//
//  Created by 김승희 on 4/6/25.
//

import UIKit


final class TabbarCoordinator: CoordinatorProtocol {

    enum Tab: Int {
        case home = 0
        case archive = 1
        case search = 2
        case mypage = 3
    }

    var childCoordinators: [CoordinatorProtocol] = []
    var navigationController: UINavigationController
    var parentCoordinator: CoordinatorProtocol?

    private let container: AppDIContainer
    private let tabBarController = UITabBarController()

    init(navigationController: UINavigationController, container: AppDIContainer) {
        self.navigationController = navigationController
        self.container = container
    }

    func start() {
        setupChildCoordinators()
        setupTabBarController()
        setupTabBarAppearance()
        navigationController.setViewControllers([tabBarController], animated: false)
    }

    func switchTab(to tab: Tab) {
        tabBarController.selectedIndex = tab.rawValue
    }

    func didLogout() {
        (parentCoordinator as? FirstCoordinator)?.didLoggedOut()
    }
}

private extension TabbarCoordinator {

    func setupChildCoordinators() {
        let coordinators: [CoordinatorProtocol] = [
            container.makeHomeCoordinator(),
            container.makeArchiveCoordinator(),
            container.makeSearchCoordinator(),
            container.makeMypageCoordinator()
        ]
        coordinators.forEach {
            addChild($0)
            $0.start()
        }
    }

    func setupTabBarController() {
        tabBarController.viewControllers = childCoordinators.enumerated().map { index, coordinator in
            let nav = coordinator.navigationController
            guard let tabItem = TabItem(rawValue: index) else { return nav }
            nav.tabBarItem = UITabBarItem(title: tabItem.title, image: tabItem.icon, tag: index)
            return nav
        }
    }

    func setupTabBarAppearance() {
        tabBarController.tabBar.backgroundColor = .white
        tabBarController.tabBar.tintColor = .primary50
        tabBarController.tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBarController.tabBar.layer.shadowOpacity = 0.1
        tabBarController.tabBar.layer.shadowOffset = CGSize(width: 0, height: 2)
        tabBarController.tabBar.layer.shadowRadius = 4
        tabBarController.tabBar.layer.masksToBounds = false
    }
}
