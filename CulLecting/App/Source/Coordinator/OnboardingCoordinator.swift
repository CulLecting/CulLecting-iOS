//
//  OnboardingCoordinator.swift
//  CulLecting
//
//  Created by 김승희 on 4/6/25.
//


import UIKit
import Swinject

public protocol OnboardingCoordinatorProtocol: Coordinator {
    func showOnboardingFlow()
}

public class OnboardingCoordinator: OnboardingCoordinatorProtocol {
    public var childCoordinators: [Coordinator] = []
    public var navigationController: UINavigationController
    public var type: CoordinatorType = .onboarding
    public weak var parentCoordinator: DefaultAppCoordinatorProtocol?
    
    public var finishDelegate: CoordinatorFinishDelegate?
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    public func start() {
        print("OnboardingCoordinator - start() 실행됨")
        showOnboardingFlow()
    }
    
    public func showOnboardingFlow() {
        print("OnboardingCoordinator - showOnboardingFlow() 실행됨")
        
        let onboardingVC = OnboardingViewController()
        onboardingVC.onFinishTransition = { [weak self] in
            guard let self = self else { return }
            let finishVC = OnboardingFinishViewController()
            finishVC.onFinish = { [weak self] in
                self?.finish()
            }
            self.navigationController.pushViewController(finishVC, animated: true)
        }
        navigationController.setViewControllers([onboardingVC], animated: false)
    }
    
    public func finish() {
        print("OnboardingCoordinator - finish() 호출됨")
        finishDelegate?.coordinatorDidFinish(childCoordinator: self)
    }
}
