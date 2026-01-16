//
//  FirstAppCoordinator.swift
//  CulLecting
//
//  Created by 김승희 on 4/6/25.
//

import UIKit

import RxSwift


final class FirstCoordinator: CoordinatorProtocol {

    var childCoordinators: [CoordinatorProtocol] = []
    var navigationController: UINavigationController
    var parentCoordinator: CoordinatorProtocol?

    private let container: AppDIContainer
    private let disposeBag = DisposeBag()

    private var hasSeenOnboarding: Bool {
        UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
    }

    init(navigationController: UINavigationController, container: AppDIContainer) {
        self.navigationController = navigationController
        self.container = container
    }

    func start() {
        navigationController.isNavigationBarHidden = true
        validateAuthenticationStatus()
    }

    func didLoggedIn() {
        clearChildCoordinators()
        hasSeenOnboarding ? showTabbarFlow() : showOnboardingFlow()
    }

    func didLoggedOut() {
        clearChildCoordinators()
        showLoginFlow()
    }
    
    func validateAuthenticationStatus() {
        guard let authUseCase = container.resolveAuthUseCase() else {
            showLoginFlow()
            return
        }

        authUseCase.validateToken()
            .observe(on: MainScheduler.instance)
            .subscribe(
                onSuccess: { [weak self] isValid in
                    self?.handleAuthValidation(isValid: isValid)
                },
                onFailure: { [weak self] _ in
                    self?.showLoginFlow()
                }
            )
            .disposed(by: disposeBag)
    }

    func handleAuthValidation(isValid: Bool) {
        if isValid {
            hasSeenOnboarding ? showTabbarFlow() : showOnboardingFlow()
        } else {
            TokenStorage.shared.clearAll()
            showLoginFlow()
        }
    }

    func showLoginFlow() {
        let coordinator = container.makeLoginCoordinator(navigationController: navigationController)
        addChild(coordinator)
        coordinator.start()
    }

    func showOnboardingFlow() {
        navigationController.isNavigationBarHidden = false
        let coordinator = container.makeOnboardingCoordinator(navigationController: navigationController)
        addChild(coordinator)
        coordinator.start()
    }

    func showTabbarFlow() {
        let coordinator = container.makeTabbarCoordinator(navigationController: navigationController)
        addChild(coordinator)
        coordinator.start()
    }

    func clearChildCoordinators() {
        childCoordinators.forEach { $0.finish() }
        childCoordinators.removeAll()
    }
}
