//
//  OnboardingAssembly.swift
//  CulLecting
//
//  Created by 김승희 on 4/7/25.
//

import Swinject


struct OnboardingAssembly: Assembly {

    func assemble(container: Container) {

        container.register(OnboardingRepository.self) { _ in
            OnboardingRepository()
        }.inObjectScope(.container)

        container.register(OnboardingUseCase.self) { r in
            OnboardingUseCase(
                repository: r.resolve(OnboardingRepository.self)!
            )
        }.inObjectScope(.container)

        container.register(OnboardingViewModel.self) { r in
            OnboardingViewModel(
                useCase: r.resolve(OnboardingUseCase.self)!
            )
        }.inObjectScope(.container)

        container.register(OnboardingViewController.self) { (r, coordinator: OnboardingCoordinator) in
            OnboardingViewController(
                viewModel: r.resolve(OnboardingViewModel.self)!,
                coordinator: coordinator
            )
        }

        container.register(OnboardingFinishViewController.self) { (r, coordinator: OnboardingCoordinator) in
            OnboardingFinishViewController(
                viewModel: r.resolve(OnboardingViewModel.self)!,
                coordinator: coordinator
            )
        }
    }
}
