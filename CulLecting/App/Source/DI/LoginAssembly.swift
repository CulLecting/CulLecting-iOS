//
//  AuthAssembly.swift
//  CulLecting
//
//  Created by 김승희 on 4/7/25.
//


import UIKit

import Swinject


final class LoginAssembly: Assembly {
    func assemble(container: Container) {
        
        container.register(AuthRepository.self) { _ in
            AuthRepository()
        }.inObjectScope(.container)
        
        container.register(AuthUseCase.self) { r in
            let repository = r.resolve(AuthRepository.self)!
            return AuthUseCase(repository: repository)
        }.inObjectScope(.container)
        
        container.register(LoginViewModel.self) { r in
            let useCase = r.resolve(AuthUseCase.self)!
            return LoginViewModel(useCase: useCase)
        }
        
        container.register(JoinViewModel.self) { r in
            let useCase = r.resolve(AuthUseCase.self)!
            return JoinViewModel(useCase: useCase)
        }
        
        container.register(LoginCoordinator.self) { (r, navigationController: UINavigationController) in
            return LoginCoordinator(navigationController: navigationController, container: r)
        }
    }
}
