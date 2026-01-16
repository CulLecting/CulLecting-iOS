//
//  MypageAssembly.swift
//  CulLecting
//
//  Created by 김승희 on 4/7/25.
//

import Swinject

struct MypageAssembly: Assembly {

    func assemble(container: Container) {
        // Repository
        container.register(AuthRepository.self) { _ in
            AuthRepository()
        }

        // UseCase
        container.register(MypageUseCase.self) { r in
            let repository = r.resolve(AuthRepository.self)!
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
