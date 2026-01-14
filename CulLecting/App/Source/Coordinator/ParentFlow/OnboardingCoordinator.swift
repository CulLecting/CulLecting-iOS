//
//  OnboardingCoordinator.swift
//  CulLecting
//
//  Created by 김승희 on 4/6/25.
//


import UIKit

import Swinject

public protocol OnboardingCoordinatorProtocol: CoordinatorProtocol {
    func showOnboardingFlow()
    func showOnboardingFinish()
    func didFinishOnboarding()
}

public class OnboardingCoordinator: OnboardingCoordinatorProtocol {

    public var childCoordinators: [CoordinatorProtocol] = []
    public var navigationController: UINavigationController
    public var type: CoordinatorType = .onboarding
    public weak var parentCoordinator: FirstCoordinatorProtocol?

    public var finishDelegate: CoordinatorFinishDelegate?

    private let container: Resolver
    private var viewModel: OnboardingViewModel?

    public init(navigationController: UINavigationController, container: Resolver) {
        self.navigationController = navigationController
        self.container = container
    }

    public func start() {
        print("OnboardingCoordinator - start() 실행됨")
        showOnboardingFlow()
    }
}

// MARK: - Navigation Methods (Pure Navigation Only)
extension OnboardingCoordinator {

    public func showOnboardingFlow() {
        print("OnboardingCoordinator - showOnboardingFlow() 실행됨")

        guard let viewModel = container.resolve(OnboardingViewModel.self) else {
            print("OnboardingCoordinator - OnboardingViewModel resolve 실패")
            return
        }

        self.viewModel = viewModel
        let onboardingVC = OnboardingViewController(viewModel: viewModel, coordinator: self)
        navigationController.setViewControllers([onboardingVC], animated: false)
    }

    public func showOnboardingFinish() {
        guard let viewModel = viewModel else { return }
        let finishVC = OnboardingFinishViewController(viewModel: viewModel, coordinator: self)
        navigationController.pushViewController(finishVC, animated: true)
    }

    public func didFinishOnboarding() {
        print("OnboardingCoordinator - didFinishOnboarding() 호출됨")
        finishDelegate?.coordinatorDidFinish(childCoordinator: self)
    }
}
