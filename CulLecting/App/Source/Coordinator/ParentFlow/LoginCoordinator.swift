//
//  LoginCoordinator.swift
//  CulLecting
//
//  Created by 김승희 on 4/6/25.
//

import UIKit


final class LoginCoordinator: CoordinatorProtocol {

    var childCoordinators: [CoordinatorProtocol] = []
    var navigationController: UINavigationController
    var parentCoordinator: CoordinatorProtocol?

    private let container: AppDIContainer

    init(navigationController: UINavigationController, container: AppDIContainer) {
        self.navigationController = navigationController
        self.container = container
    }

    func start() {
        let loginVC = container.makeLoginViewController(coordinator: self)
        navigationController.setViewControllers([loginVC], animated: false)
    }
    
    func didCompleteSignup() {
        (parentCoordinator as? FirstCoordinator)?.showOnboardingFlow()
    }
    
    func showLoginView() {
        let loginVC = container.makeLoginViewController(coordinator: self)
        navigationController.pushViewController(loginVC, animated: true)
    }

    func showJoinView() {
        let joinVC = container.makeJoinViewController(coordinator: self)
        navigationController.pushViewController(joinVC, animated: true)
    }

    func showResetPassword() {
        let resetVC = container.makeResetPasswordViewController(coordinator: self)
        navigationController.pushViewController(resetVC, animated: true)
    }

    func didLoginSuccess() {
        (parentCoordinator as? FirstCoordinator)?.didLoggedIn()
    }

    func continueAsGuest() {
        (parentCoordinator as? FirstCoordinator)?.didLoggedIn()
    }
}
