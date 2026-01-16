//
//  OnboardingCoordinator.swift
//  CulLecting
//
//  Created by 김승희 on 4/6/25.
//

import UIKit


final class OnboardingCoordinator: CoordinatorProtocol {
    
    var childCoordinators: [CoordinatorProtocol] = []
    var navigationController: UINavigationController
    var parentCoordinator: CoordinatorProtocol?
    
    private let container: AppDIContainer
    
    init(navigationController: UINavigationController, container: AppDIContainer) {
        self.navigationController = navigationController
        self.container = container
    }
    
    func start() {
        let onboardingVC = container.makeOnboardingViewController(coordinator: self)
        navigationController.setViewControllers([onboardingVC], animated: false)
    }
    
    func showOnboardingFinish() {
        let finishVC = container.makeOnboardingFinishViewController(coordinator: self)
        navigationController.pushViewController(finishVC, animated: true)
    }
    
    func didFinishOnboarding() {
        (parentCoordinator as? FirstCoordinator)?.didLoggedIn()
    }
}
