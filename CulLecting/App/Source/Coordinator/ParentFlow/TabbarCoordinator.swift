//
//  TabbarCoordinator.swift
//  CulLecting
//
//  Created by 김승희 on 4/6/25.
//


import UIKit

import Swinject

public final class TabbarCoordinator: CoordinatorProtocol {
    
    // MARK: Dependency
    public struct Dependency {
        let navigationController: UINavigationController
        let injector: Resolver
        weak var finishDelegate: CoordinatorFinishDelegate?
        
        public init(
            navigationController: UINavigationController,
            injector: Resolver,
            finishDelegate: CoordinatorFinishDelegate? = nil
        ) {
            self.navigationController = navigationController
            self.injector = injector
            self.finishDelegate = finishDelegate
        }
    }
    
    // MARK: Properties
    public var childCoordinators: [CoordinatorProtocol] = []
    public var navigationController: UINavigationController
    public var type: CoordinatorType = .tabbar
    public weak var finishDelegate: CoordinatorFinishDelegate?
    public weak var parentCoordinator: FirstCoordinatorProtocol?
    
    private let dependency: Dependency
    private let tabBarController = UITabBarController()
    
    // MARK: init
    public init(dependency: Dependency) {
        self.dependency = dependency
        self.navigationController = dependency.navigationController
    }
    
    // MARK: Start
    public func start() {
        setupChildCoordinators()
        setupTabBarController()
        setTabBarAppearance()
        
        navigationController.setViewControllers([tabBarController], animated: false)
    }
    
    // MARK: Finish
    public func finish() {
        childCoordinators.forEach { $0.finish() }
        childCoordinators.removeAll()
        finishDelegate?.coordinatorDidFinish(childCoordinator: self)
    }
}

// MARK: methods
extension TabbarCoordinator {
    
    func setupChildCoordinators() {
        let homeCoordinator = HomeCoordinator(injector: dependency.injector)
        let archiveCoordinator = ArchiveCoordinator(injector: dependency.injector)
        let searchCoordinator = SearchCoordinator(injector: dependency.injector)
        let myPageCoordinator = MypageCoordinator(injector: dependency.injector)
        
        homeCoordinator.parentCoordinator = self
        archiveCoordinator.parentCoordinator = self
        searchCoordinator.parentCoordinator = self
        myPageCoordinator.parentCoordinator = self
        
        childCoordinators = [
            homeCoordinator,
            archiveCoordinator,
            searchCoordinator,
            myPageCoordinator
        ]
        
        childCoordinators.forEach { $0.start() }
    }
    
    func setupTabBarController() {
        tabBarController.viewControllers = childCoordinators.enumerated().map { (index, coordinator) in
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
    
    func setTabBarAppearance() {
        tabBarController.tabBar.backgroundColor = .white
        tabBarController.tabBar.tintColor = .primary50
        tabBarController.tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBarController.tabBar.layer.shadowOpacity = 0.1
        tabBarController.tabBar.layer.shadowOffset = CGSize(width: 0, height: 2)
        tabBarController.tabBar.layer.shadowRadius = 4
        tabBarController.tabBar.layer.masksToBounds = false
    }
    
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
    
    func logoutAndStartLoginFlow() {
        print("logoutAndStartLoginFlow called")
        parentCoordinator?.didLoggedOut()
    }

}
