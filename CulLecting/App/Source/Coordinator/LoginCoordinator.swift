//
//  LoginCoordinator.swift
//  CulLecting
//
//  Created by 김승희 on 4/6/25.
//

import UIKit
import Swinject

public protocol LoginCoordinatorProtocol: Coordinator {
    func showLoginFlow()
    func didLoginSuccess()
    func showJoinView()
}

public final class LoginCoordinator: LoginCoordinatorProtocol {

    public var childCoordinators: [Coordinator] = []
    public var navigationController: UINavigationController
    public var type: CoordinatorType = .login
    public weak var parentCoordinator: DefaultAppCoordinatorProtocol?
    
    public var finishDelegate: CoordinatorFinishDelegate?
    
    private let container: Resolver
    
    public init(navigationController: UINavigationController, container: Resolver) {
        self.navigationController = navigationController
        self.container = container
    }
    
    public func start() {
        showLoginFlow()
    }
    
    public func showLoginFlow() {
        guard let viewModel = container.resolve(LoginViewModel.self) else { return }
        let loginVC = LoginViewController(viewModel: viewModel, coordinator: self)
        navigationController.setViewControllers([loginVC], animated: false)
    }
    
    public func didLoginSuccess() {
        parentCoordinator?.didLoggedIn()
    }
    
    public func showJoinView() {
        print("LoginCoordinator - showJoinView 호출됨")
        guard let viewModel = container.resolve(JoinViewModel.self) else {
            print("LoginCoordinator - JoinViewModel resolve 실패")
            return
        }

        let joinVC = JoinViewController(viewModel: viewModel)
        navigationController.pushViewController(joinVC, animated: true)
    }

}
