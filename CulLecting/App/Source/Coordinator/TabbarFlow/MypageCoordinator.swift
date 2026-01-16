//
//  MypageCoordinator.swift
//  CulLecting
//
//  Created by 김승희 on 4/25/25.
//

import UIKit


final class MypageCoordinator: CoordinatorProtocol {

    var childCoordinators: [CoordinatorProtocol] = []
    var navigationController: UINavigationController
    var parentCoordinator: CoordinatorProtocol?

    private let container: AppDIContainer

    init(container: AppDIContainer) {
        self.container = container
        self.navigationController = UINavigationController()
    }

    func start() {
        let mypageVC = container.makeMypageViewController(coordinator: self)
        navigationController.setViewControllers([mypageVC], animated: false)
    }

    func didLogout() {
        (parentCoordinator as? TabbarCoordinator)?.didLogout()
    }
}
