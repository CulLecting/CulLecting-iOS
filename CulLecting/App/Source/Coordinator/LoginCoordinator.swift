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
}

public final class LoginCoordinator: LoginCoordinatorProtocol {

    public var childCoordinators: [Coordinator] = []
    public var navigationController: UINavigationController
    public var type: CoordinatorType = .login
    public weak var parentCoordinator: DefaultAppCoordinatorProtocol?
    
    public var finishDelegate: CoordinatorFinishDelegate?
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    public func start() {
        showLoginFlow()
    }
    
    public func showLoginFlow() {
        let loginVC = LoginViewController()
        // 예: 로그인 성공 시 부모 코디네이터에게 알리는 클로저를 설정할 수 있음
        navigationController.setViewControllers([loginVC], animated: false)
    }
}
