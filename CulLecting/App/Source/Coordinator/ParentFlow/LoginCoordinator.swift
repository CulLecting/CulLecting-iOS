//
//  LoginCoordinator.swift
//  CulLecting
//
//  Created by 김승희 on 4/6/25.
//

import UIKit

public protocol LoginCoordinatorProtocol: CoordinatorProtocol {
    func showLoginFlow()
    func didLoginSuccess()
    func showJoinView()
    func showResetPassword()
    func continueAsGuest()
}

public final class LoginCoordinator: LoginCoordinatorProtocol {

    public var childCoordinators: [CoordinatorProtocol] = []
    public var navigationController: UINavigationController
    public var parentCoordinator: CoordinatorProtocol?

    private let container: AppDIContainer

    public init(navigationController: UINavigationController, container: AppDIContainer) {
        self.navigationController = navigationController
        self.container = container
    }

    public func start() {
        showLoginFlow()
    }

    // MARK: - Navigation

    public func showLoginFlow() {
        let loginVC = container.makeLoginViewController(coordinator: self)
        navigationController.setViewControllers([loginVC], animated: false)
    }

    public func showJoinView() {
        let joinVC = container.makeJoinViewController(coordinator: self)
        navigationController.pushViewController(joinVC, animated: true)
    }

    public func showResetPassword() {
        let resetVC = container.makeResetPasswordViewController(coordinator: self)
        navigationController.pushViewController(resetVC, animated: true)
    }

    // MARK: - Flow Completion

    public func didLoginSuccess() {
        (parentCoordinator as? FirstCoordinator)?.didLoggedIn()
    }

    public func continueAsGuest() {
        (parentCoordinator as? FirstCoordinator)?.didLoggedIn()
    }
}
