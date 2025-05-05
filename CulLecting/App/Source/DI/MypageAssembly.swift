//
//  MypageAssembly.swift
//  CulLecting
//
//  Created by 김승희 on 4/7/25.
//


import UIKit

import Swinject


public struct MypageAssembly: Assembly {
    public func assemble(container: Container) {
        container.register(AuthRepository.self) { _ in
            AuthRepository()
        }

        container.register(MypageUseCase.self) { r in
            let repository = r.resolve(AuthRepository.self)!
            return MypageUseCase(repository: repository)
        }

        container.register(MypageViewModel.self) { r in
            let useCase = r.resolve(MypageUseCase.self)!
            return MypageViewModel(useCase: useCase)
        }

        container.register(MypageCoordinator.self) { (r, navigationController: UINavigationController) in
            return MypageCoordinator(injector: r)
        }
    }
}
