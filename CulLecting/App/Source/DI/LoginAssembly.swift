//
//  AuthAssembly.swift
//  CulLecting
//
//  Created by 김승희 on 4/7/25.
//

import Swinject

struct LoginAssembly: Assembly {

    func assemble(container: Container) {
        // Repository
        container.register(AuthRepository.self) { _ in
            AuthRepository()
        }.inObjectScope(.container)

        // UseCase
        container.register(AuthUseCase.self) { r in
            let repository = r.resolve(AuthRepository.self)!
            return AuthUseCase(repository: repository)
        }.inObjectScope(.container)

        container.register(AuthUseCaseProtocol.self) { r in
            r.resolve(AuthUseCase.self)!
        }.inObjectScope(.container)

        // ViewModel
        container.register(LoginViewModel.self) { r in
            let useCase = r.resolve(AuthUseCase.self)!
            return LoginViewModel(useCase: useCase)
        }

        container.register(JoinViewModel.self) { r in
            let useCase = r.resolve(AuthUseCase.self)!
            return JoinViewModel(useCase: useCase)
        }

        container.register(ResetPasswordViewModel.self) { r in
            let useCase = r.resolve(AuthUseCase.self)!
            return ResetPasswordViewModel(useCase: useCase)
        }

        // ViewController
        container.register(LoginViewController.self) { (r, coordinator: LoginCoordinator) in
            let viewModel = r.resolve(LoginViewModel.self)!
            return LoginViewController(viewModel: viewModel, coordinator: coordinator)
        }

        container.register(JoinViewController.self) { (r, coordinator: LoginCoordinator) in
            let viewModel = r.resolve(JoinViewModel.self)!
            return JoinViewController(viewModel: viewModel, coordinator: coordinator)
        }

        container.register(ResetPasswordViewController.self) { (r, coordinator: LoginCoordinator) in
            let viewModel = r.resolve(ResetPasswordViewModel.self)!
            return ResetPasswordViewController(viewModel: viewModel, coordinator: coordinator)
        }
    }
}
