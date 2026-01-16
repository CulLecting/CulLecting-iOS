//
//  SearchCoordinator.swift
//  CulLecting
//
//  Created by 김승희 on 4/25/25.
//

import UIKit


final class SearchCoordinator: CoordinatorProtocol {

    var childCoordinators: [CoordinatorProtocol] = []
    var navigationController: UINavigationController
    var parentCoordinator: CoordinatorProtocol?

    private let container: AppDIContainer

    init(container: AppDIContainer) {
        self.container = container
        self.navigationController = UINavigationController()
    }

    func start() {
        let searchVC = container.makeSearchViewController(coordinator: self)
        navigationController.setViewControllers([searchVC], animated: false)
    }
}
