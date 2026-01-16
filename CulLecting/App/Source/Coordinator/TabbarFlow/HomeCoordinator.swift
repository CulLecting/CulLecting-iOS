//
//  HomeCoordinator.swift
//  CulLecting
//
//  Created by 김승희 on 4/25/25.
//

import UIKit


final class HomeCoordinator: CoordinatorProtocol {

    var childCoordinators: [CoordinatorProtocol] = []
    var navigationController: UINavigationController
    var parentCoordinator: CoordinatorProtocol?

    private let container: AppDIContainer

    init(container: AppDIContainer) {
        self.container = container
        self.navigationController = UINavigationController()
    }

    func start() {
        let homeVC = container.makeHomeViewController(coordinator: self)
        navigationController.setViewControllers([homeVC], animated: false)
    }

    func moveToArchiveTab() {
        (parentCoordinator as? TabbarCoordinator)?.switchTab(to: .archive)
    }
}
