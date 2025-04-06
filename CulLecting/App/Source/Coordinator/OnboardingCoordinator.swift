//
//  OnboardingCoordinator.swift
//  CulLecting
//
//  Created by 김승희 on 4/6/25.
//


import UIKit
import Swinject

protocol OnboardingCoordinatorProtocol: Coordinator {
    func showOnboardingFlow()
}

public class OnboardingCoordinator: OnboardingCoordinatorProtocol {
 
    public var childCoordinators: [any Coordinator] = []
    public var navigationController: UINavigationController
    public var type: CoordinatorType = .onboarding
    public weak var parentCoordinator: DefaultAppCoordinatorProtocol?
    
    public var finishDelegate: (any CoordinatorFinishDelegate)?
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    public func start() {
        showOnboardingFlow()
    }
    
    public func showOnboardingFlow() {
        let onboardingVC = OnboardingViewController()
        // 예: 로그인 성공 시 부모 코디네이터에게 알리는 클로저를 설정할 수 있음
        navigationController.setViewControllers([onboardingVC], animated: false)
    }
    
}
