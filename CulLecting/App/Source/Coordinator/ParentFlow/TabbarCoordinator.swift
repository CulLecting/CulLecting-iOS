//
//  TabbarCoordinator.swift
//  CulLecting
//
//  Created by 김승희 on 4/6/25.
//

import UIKit

public final class TabbarCoordinator: CoordinatorProtocol {

    public var childCoordinators: [CoordinatorProtocol] = []
    public var navigationController: UINavigationController
    public var parentCoordinator: CoordinatorProtocol?

    private let container: AppDIContainer
    private let tabBarController = UITabBarController()

    public init(navigationController: UINavigationController, container: AppDIContainer) {
        self.navigationController = navigationController
        self.container = container
    }

    public func start() {
        setupChildCoordinators()
        setupTabBarController()
        setTabBarAppearance()
        navigationController.setViewControllers([tabBarController], animated: false)
    }

    // MARK: - Setup

    private func setupChildCoordinators() {
        let homeCoordinator = container.makeHomeCoordinator()
        let archiveCoordinator = container.makeArchiveCoordinator()
        let searchCoordinator = container.makeSearchCoordinator()
        let mypageCoordinator = container.makeMypageCoordinator()

        [homeCoordinator, archiveCoordinator, searchCoordinator, mypageCoordinator].forEach {
            addChild($0)
            $0.start()
        }
    }

    private func setupTabBarController() {
        tabBarController.viewControllers = childCoordinators.enumerated().map { index, coordinator in
            let nav = coordinator.navigationController
            guard let tabItem = TabItem(rawValue: index) else { return nav }
            nav.tabBarItem = UITabBarItem(
                title: tabItem.title,
                image: tabItem.icon,
                tag: index
            )
            return nav
        }
    }

    private func setTabBarAppearance() {
        tabBarController.tabBar.backgroundColor = .white
        tabBarController.tabBar.tintColor = .primary50
        tabBarController.tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBarController.tabBar.layer.shadowOpacity = 0.1
        tabBarController.tabBar.layer.shadowOffset = CGSize(width: 0, height: 2)
        tabBarController.tabBar.layer.shadowRadius = 4
        tabBarController.tabBar.layer.masksToBounds = false
    }

    // MARK: - Tab Switching

    func switchTab(to type: CoordinatorType) {
        switch type {
        case .home:
            tabBarController.selectedIndex = 0
        case .archive:
            tabBarController.selectedIndex = 1
        case .search:
            tabBarController.selectedIndex = 2
        case .mypage:
            tabBarController.selectedIndex = 3
        default:
            break
        }
    }

    // MARK: - Logout

    func didLogout() {
        (parentCoordinator as? FirstCoordinator)?.didLoggedOut()
    }
}
