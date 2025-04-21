//
//  OnboardingAssembly.swift
//  CulLecting
//
//  Created by 김승희 on 4/7/25.
//


import UIKit

import Swinject

struct OnboardingAssembly: Assembly {
    func assemble(container: Container) {
        container.register(OnboardingRepository.self) { _ in
            OnboardingRepository()
        }.inObjectScope(.container)
        
        container.register(OnboardingUseCase.self) { r in
            let repo = r.resolve(OnboardingRepository.self)!
            return OnboardingUseCase(repository: repo)
        }.inObjectScope(.container)
        
        container.register(OnboardingViewModel.self) { r in
            let useCase = r.resolve(OnboardingUseCase.self)!
            return OnboardingViewModel(useCase: useCase)
        }
        
        container.register(OnboardingCoordinator.self) { (r, navigationController: UINavigationController) in
            return OnboardingCoordinator(navigationController: navigationController, container: r)
        }
    }
}
