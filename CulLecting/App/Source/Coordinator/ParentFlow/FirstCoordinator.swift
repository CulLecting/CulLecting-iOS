//
//  FirstAppCoordinator.swift
//  CulLecting
//
//  Created by 김승희 on 4/6/25.
//

import UIKit

import RxSwift

final class FirstCoordinator: CoordinatorProtocol {

    private enum UserDefaultsKey {
        static let hasSeenOnboarding = "hasSeenOnboarding"
    }

    private let container: AppDIContainer
    private let disposeBag = DisposeBag()

    var childCoordinators: [CoordinatorProtocol] = []
    var navigationController: UINavigationController
    var parentCoordinator: CoordinatorProtocol?

    private var hasSeenOnboarding: Bool {
        UserDefaults.standard.bool(forKey: UserDefaultsKey.hasSeenOnboarding)
    }

    init(navigationController: UINavigationController, container: AppDIContainer) {
        self.navigationController = navigationController
        self.container = container
    }

    func start() {
        navigationController.isNavigationBarHidden = true
        validateAuthenticationStatus()
    }

    // MARK: - Authentication

    private func validateAuthenticationStatus() {
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

    private func handleAuthValidation(isValid: Bool) {
        if isValid {
            hasSeenOnboarding ? showTabbarFlow() : showOnboardingFlow()
        } else {
            TokenStorage.shared.clearAll()
            showLoginFlow()
        }
    }

    // MARK: - Flow Presentation

    private func showLoginFlow() {
        let loginCoordinator = container.makeLoginCoordinator(navigationController: navigationController)
        addChild(loginCoordinator)
        loginCoordinator.start()
    }

    private func showOnboardingFlow() {
        navigationController.isNavigationBarHidden = false
        let onboardingCoordinator = container.makeOnboardingCoordinator(navigationController: navigationController)
        addChild(onboardingCoordinator)
        onboardingCoordinator.start()
    }

    private func showTabbarFlow() {
        let tabbarCoordinator = container.makeTabbarCoordinator(navigationController: navigationController)
        addChild(tabbarCoordinator)
        tabbarCoordinator.start()
    }

    // MARK: - Child Coordinator Callbacks

    func didLoggedIn() {
        clearChildCoordinators()
        hasSeenOnboarding ? showTabbarFlow() : showOnboardingFlow()
    }

    func didLoggedOut() {
        clearChildCoordinators()
        showLoginFlow()
    }

    private func clearChildCoordinators() {
        childCoordinators.forEach { $0.finish() }
        childCoordinators.removeAll()
    }
}
