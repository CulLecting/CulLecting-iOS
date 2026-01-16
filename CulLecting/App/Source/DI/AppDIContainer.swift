//
//  AppDIContainer.swift
//  CulLecting
//
//  Created by 김승희 on 1/16/26.
//

import UIKit

import Swinject

final class AppDIContainer {

    private let container: Container

    init(container: Container) {
        self.container = container
    }

    // MARK: - Coordinators

    func makeFirstCoordinator(navigationController: UINavigationController) -> FirstCoordinator {
        FirstCoordinator(navigationController: navigationController, container: self)
    }

    func makeLoginCoordinator(navigationController: UINavigationController) -> LoginCoordinator {
        LoginCoordinator(navigationController: navigationController, container: self)
    }

    func makeOnboardingCoordinator(navigationController: UINavigationController) -> OnboardingCoordinator {
        OnboardingCoordinator(navigationController: navigationController, container: self)
    }

    func makeTabbarCoordinator(navigationController: UINavigationController) -> TabbarCoordinator {
        TabbarCoordinator(navigationController: navigationController, container: self)
    }

    func makeHomeCoordinator() -> HomeCoordinator {
        HomeCoordinator(container: self)
    }

    func makeArchiveCoordinator() -> ArchiveCoordinator {
        ArchiveCoordinator(container: self)
    }

    func makeSearchCoordinator() -> SearchCoordinator {
        SearchCoordinator(container: self)
    }

    func makeMypageCoordinator() -> MypageCoordinator {
        MypageCoordinator(container: self)
    }

    // MARK: - Login Flow

    func makeLoginViewController(coordinator: LoginCoordinatorProtocol) -> LoginViewController {
        let viewModel = container.resolve(LoginViewModel.self)!
        return LoginViewController(viewModel: viewModel, coordinator: coordinator)
    }

    func makeJoinViewController(coordinator: LoginCoordinatorProtocol) -> JoinViewController {
        let viewModel = container.resolve(JoinViewModel.self)!
        return JoinViewController(viewModel: viewModel, coordinator: coordinator)
    }

    func makeResetPasswordViewController(coordinator: LoginCoordinatorProtocol) -> ResetPasswordViewController {
        let viewModel = container.resolve(ResetPasswordViewModel.self)!
        return ResetPasswordViewController(viewModel: viewModel, coordinator: coordinator)
    }

    // MARK: - Onboarding Flow

    func makeOnboardingViewController(
        viewModel: OnboardingViewModel,
        coordinator: OnboardingCoordinatorProtocol
    ) -> OnboardingViewController {
        OnboardingViewController(viewModel: viewModel, coordinator: coordinator)
    }

    func makeOnboardingFinishViewController(
        viewModel: OnboardingViewModel,
        coordinator: OnboardingCoordinatorProtocol
    ) -> OnboardingFinishViewController {
        OnboardingFinishViewController(viewModel: viewModel, coordinator: coordinator)
    }

    func makeOnboardingViewModel() -> OnboardingViewModel {
        container.resolve(OnboardingViewModel.self)!
    }

    // MARK: - Home Flow

    func makeHomeViewController(coordinator: HomeCoordinator) -> HomeViewController {
        let viewModel = container.resolve(HomeViewModel.self)!
        return HomeViewController(viewModel: viewModel, coordinator: coordinator)
    }

    // MARK: - Archive Flow

    func makeArchiveViewController(coordinator: ArchiveCoordinator) -> ArchiveViewController {
        let viewModel = container.resolve(ArchiveViewModel.self)!
        return ArchiveViewController(viewModel: viewModel, coordinator: coordinator)
    }

    func makeSearchCulturalInfoViewController(
        coordinator: ArchiveCoordinator,
        actionType: TicketActionType
    ) -> SearchCulutralInfoViewController {
        let viewModel = container.resolve(SearchCulturalInfoViewModel.self, argument: actionType)!
        return SearchCulutralInfoViewController(viewModel: viewModel, coordinator: coordinator, actionType: actionType)
    }

    func makePhotoPreviewViewController(
        image: UIImage,
        onConfirm: @escaping (UIImage) -> Void
    ) -> PhotoPreviewViewController {
        PhotoPreviewViewController(image: image, onConfirm: onConfirm)
    }

    func makeTicketDetailViewController(
        coordinator: ArchiveCoordinator,
        ticket: Ticket
    ) -> TicketDetailViewController {
        let viewModel = container.resolve(TicketDetailViewModel.self)!
        return TicketDetailViewController(viewModel: viewModel, ticket: ticket, coordinator: coordinator)
    }

    func makeTicketEditViewController(ticket: Ticket) -> TicketEditViewController {
        let useCase = container.resolve(ArchivingUseCase.self)!
        let viewModel = TicketEditViewModel(useCase: useCase, ticket: ticket)
        return TicketEditViewController(ticket: ticket, viewModel: viewModel)
    }

    // MARK: - Search Flow

    func makeSearchViewController(coordinator: SearchCoordinator) -> SearchViewController {
        let viewModel = container.resolve(SearchViewModel.self)!
        return SearchViewController(viewModel: viewModel, coordinator: coordinator)
    }

    // MARK: - Mypage Flow

    func makeMypageViewController(coordinator: MypageCoordinator) -> MypageViewController {
        let viewModel = container.resolve(MypageViewModel.self)!
        return MypageViewController(viewModel: viewModel, coordinator: coordinator)
    }

    // MARK: - UseCases (for coordinators that need direct access)

    func resolveAuthUseCase() -> AuthUseCaseProtocol? {
        container.resolve(AuthUseCaseProtocol.self)
    }
}
