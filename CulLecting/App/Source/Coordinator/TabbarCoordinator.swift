//
//  TabbarCoordinator.swift
//  CulLecting
//
//  Created by 김승희 on 4/6/25.
//


import UIKit
import Swinject

public final class TabbarCoordinator: Coordinator {
    
    // DI Container(Resolver)와 필요한 의존성을 주입받기 위한 구조체
    public struct Dependency {
        let navigationController: UINavigationController
        let injector: Resolver
        weak var finishDelegate: CoordinatorFinishDelegate?
        
        public init(navigationController: UINavigationController,
                    injector: Resolver,
                    finishDelegate: CoordinatorFinishDelegate? = nil) {
            self.navigationController = navigationController
            self.injector = injector
            self.finishDelegate = finishDelegate
        }
    }
    
    private let dependency: Dependency
    public var childCoordinators: [Coordinator] = []
    public var navigationController: UINavigationController
    public var type: CoordinatorType = .tabbar
    public weak var parentCoordinator: DefaultAppCoordinatorProtocol?
    public var finishDelegate: (any CoordinatorFinishDelegate)?
    
    public let tabBarController: UITabBarController
    
    public init(dependency: Dependency) {
        self.dependency = dependency
        self.navigationController = dependency.navigationController
        self.tabBarController = UITabBarController()
    }
    
    public func start() {
        // DI Container를 사용하여 resolve
        let homeVC = dependency.injector.resolve(HomeViewController.self) ?? UIViewController()
        homeVC.tabBarItem = UITabBarItem(title: "홈", image: UIImage.tabbarHome , tag: 0)
        
        let archivingVC = UIViewController()
        archivingVC.view.backgroundColor = .systemGreen
        archivingVC.tabBarItem = UITabBarItem(title: "내 기록", image: UIImage.tabbarArchive, tag: 1)
        
        let searchVC = UIViewController()
        searchVC.view.backgroundColor = .systemOrange
        searchVC.tabBarItem = UITabBarItem(title: "검색", image: UIImage.tabbarSearch, tag: 2)
        
        let myPageVC = dependency.injector.resolve(MyPageViewController.self) ?? UIViewController()
        myPageVC.view.backgroundColor = .systemPurple
        myPageVC.tabBarItem = UITabBarItem(title: "마이", image: UIImage.tabbarMyPage, tag: 3)
        
        tabBarController.viewControllers = [homeVC, archivingVC, searchVC, myPageVC]
        setTabbar()
        navigationController.setViewControllers([tabBarController], animated: false)
    }
    
    private func setTabbar() {
        tabBarController.tabBar.backgroundColor = .white
        tabBarController.tabBar.tintColor = .primary50
    }
}
