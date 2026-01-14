//
//  FirstAppCoordinator.swift
//  CulLecting
//
//  Created by 김승희 on 4/6/25.
//

import UIKit

import RxSwift
import Swinject


class FirstCoordinator: CoordinatorProtocol {
    
    struct Dependency {
        let navigationController: UINavigationController
        let injector: Resolver
    }
    
    private let dependency: Dependency
    public var childCoordinators: [CoordinatorProtocol] = []
    public var navigationController: UINavigationController
    public var parentCoordinator: CoordinatorProtocol?
    
    private let disposeBag = DisposeBag()
    
    private var haveToken: Bool {
        TokenStorage.shared.accessToken != nil
    }
    
    private var hasSeenOnboarding: Bool {
        UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
    }
    
    init(dependency: Dependency) {
        self.dependency = dependency
        self.navigationController = dependency.navigationController
    }
    
    func start() {
        navigationController.isNavigationBarHidden = true
        validateAuthenticationStatus()
    }
    
    func finish() {
        childCoordinators.removeAll()
    }
    
    // MARK: - 인증 상태 확인 (FirstCoordinator의 핵심 책임)
    private func validateAuthenticationStatus() {
        guard let authUseCase = dependency.injector.resolve(AuthUseCaseProtocol.self) else {
            showLoginFlow()
            return
        }
        
        authUseCase.validateToken()
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] isValid in
                self?.handleAuthValidation(isValid: isValid)
            })
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
    
    // MARK: - Flow 시작
    private func showLoginFlow() {
        guard let loginCoordinator = dependency.injector.resolve(LoginCoordinator.self, argument: navigationController) else {
            return
        }
        
        childCoordinators.append(loginCoordinator)
        loginCoordinator.parentCoordinator = self
        
        navigationController.setViewControllers([loginCoordinator.navigationController], animated: false)
        loginCoordinator.start()
    }
    
    private func showOnboardingFlow() {
        navigationController.isNavigationBarHidden = false
        
        guard let onboardingCoordinator = dependency.injector.resolve(OnboardingCoordinator.self, argument: navigationController) else {
            return
        }
        
        childCoordinators.append(onboardingCoordinator)
        onboardingCoordinator.parentCoordinator = self
        
        navigationController.setViewControllers([onboardingCoordinator.navigationController], animated: false)
        onboardingCoordinator.start()
    }
    
    private func showTabbarFlow() {
        guard let tabbarCoordinator = dependency.injector.resolve(TabbarCoordinator.self, argument: navigationController) else {
            return
        }
        
        childCoordinators.append(tabbarCoordinator)
        tabbarCoordinator.parentCoordinator = self
        
        navigationController.setViewControllers([tabbarCoordinator.navigationController], animated: false)
        tabbarCoordinator.start()
    }
    
    func didLoggedIn() {
        childCoordinators.removeAll()
        hasSeenOnboarding ? showTabbarFlow() : showOnboardingFlow()
    }
    
    func didLoggedOut() {
        childCoordinators.removeAll()
        showLoginFlow()
    }
}
