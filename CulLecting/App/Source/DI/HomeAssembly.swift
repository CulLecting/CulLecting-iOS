//
//  HomeAssembly.swift
//  CulLecting
//
//  Created by 김승희 on 4/7/25.
//


import UIKit

import Swinject

public struct HomeAssembly: Assembly {
    public func assemble(container: Container) {
        container.register(HomeRepository.self) { _ in
            HomeRepository()
        }

        container.register(HomeUseCase.self) { r in
            let repository = r.resolve(HomeRepository.self)!
            return HomeUseCase(repository: repository)
        }

        container.register(HomeViewModel.self) { r in
            let useCase = r.resolve(HomeUseCase.self)!
            return HomeViewModel(useCase: useCase)
        }

        container.register(HomeCoordinator.self) { (r, navigationController: UINavigationController) in
            return HomeCoordinator(injector: r)
        }
    }
}
