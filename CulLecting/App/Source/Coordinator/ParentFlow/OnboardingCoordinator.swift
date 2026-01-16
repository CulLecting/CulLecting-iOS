//
//  OnboardingCoordinator.swift
//  CulLecting
//
//  Created by 김승희 on 4/6/25.
//

import UIKit

public protocol OnboardingCoordinatorProtocol: CoordinatorProtocol {
    func showOnboardingFlow()
    func showOnboardingFinish()
    func didFinishOnboarding()
}

public final class OnboardingCoordinator: OnboardingCoordinatorProtocol {

    public var childCoordinators: [CoordinatorProtocol] = []
    public var navigationController: UINavigationController
    public var parentCoordinator: CoordinatorProtocol?

    private let container: AppDIContainer
    private var viewModel: OnboardingViewModel?

    public init(navigationController: UINavigationController, container: AppDIContainer) {
        self.navigationController = navigationController
        self.container = container
    }

    public func start() {
        showOnboardingFlow()
    }

    // MARK: - Navigation

    public func showOnboardingFlow() {
        let viewModel = container.makeOnboardingViewModel()
        self.viewModel = viewModel

        let onboardingVC = container.makeOnboardingViewController(viewModel: viewModel, coordinator: self)
        navigationController.setViewControllers([onboardingVC], animated: false)
    }

    public func showOnboardingFinish() {
        guard let viewModel = viewModel else { return }
        let finishVC = container.makeOnboardingFinishViewController(viewModel: viewModel, coordinator: self)
        navigationController.pushViewController(finishVC, animated: true)
    }

    // MARK: - Flow Completion

    public func didFinishOnboarding() {
        (parentCoordinator as? FirstCoordinator)?.didLoggedIn()
    }
}
