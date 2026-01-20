//
//  MypageAssembly.swift
//  CulLecting
//
//  Created by 김승희 on 4/7/25.
//

import Swinject

struct MypageAssembly: Assembly {

    func assemble(container: Container) {
        // UseCase - Use AuthRepositoryProtocol to support mock injection
        container.register(MypageUseCase.self) { r in
            let repository = r.resolve(AuthRepositoryProtocol.self)!
            return MypageUseCase(authRepository: repository)
        }

        // ViewModel
        container.register(MypageViewModel.self) { r in
            let useCase = r.resolve(MypageUseCase.self)!
            let authUseCase = r.resolve(AuthUseCaseProtocol.self)!
            return MypageViewModel(useCase: useCase, authUseCase: authUseCase)
        }

        // ViewController
        container.register(MypageViewController.self) { (r, coordinator: MypageCoordinator) in
            let viewModel = r.resolve(MypageViewModel.self)!
            return MypageViewController(viewModel: viewModel, coordinator: coordinator)
        }
    }
}
