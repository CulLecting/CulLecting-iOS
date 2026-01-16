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

    func makeLoginViewController(coordinator: LoginCoordinator) -> LoginViewController {
        container.resolve(LoginViewController.self, argument: coordinator)!
    }

    func makeJoinViewController(coordinator: LoginCoordinator) -> JoinViewController {
        container.resolve(JoinViewController.self, argument: coordinator)!
    }

    func makeResetPasswordViewController(coordinator: LoginCoordinator) -> ResetPasswordViewController {
        container.resolve(ResetPasswordViewController.self, argument: coordinator)!
    }

    // MARK: - Onboarding Flow
    
    func makeOnboardingViewController(coordinator: OnboardingCoordinator) -> OnboardingViewController {
        container.resolve(OnboardingViewController.self, argument: coordinator)!
    }

    func makeOnboardingFinishViewController(coordinator: OnboardingCoordinator) -> OnboardingFinishViewController {
        container.resolve(OnboardingFinishViewController.self, argument: coordinator)!
    }

    // MARK: - Home Flow

    func makeHomeViewController(coordinator: HomeCoordinator) -> HomeViewController {
        container.resolve(HomeViewController.self, argument: coordinator)!
    }

    // MARK: - Archive Flow

    func makeArchiveViewController(coordinator: ArchiveCoordinator) -> ArchiveViewController {
        container.resolve(ArchiveViewController.self, argument: coordinator)!
    }

    func makeSearchCulturalInfoViewController(coordinator: ArchiveCoordinator, actionType: TicketActionType) -> SearchCulutralInfoViewController {
        container.resolve(SearchCulutralInfoViewController.self, arguments: coordinator, actionType)!
    }

    func makePhotoPreviewViewController(image: UIImage, onConfirm: @escaping (UIImage) -> Void) -> PhotoPreviewViewController {
        container.resolve(PhotoPreviewViewController.self, arguments: image, onConfirm)!
    }

    func makeTicketDetailViewController(coordinator: ArchiveCoordinator, ticket: Ticket) -> TicketDetailViewController {
        container.resolve(TicketDetailViewController.self, arguments: coordinator, ticket)!
    }

    func makeTicketEditViewController(ticket: Ticket) -> TicketEditViewController {
        container.resolve(TicketEditViewController.self, argument: ticket)!
    }

    // MARK: - Search Flow

    func makeSearchViewController(coordinator: SearchCoordinator) -> SearchViewController {
        container.resolve(SearchViewController.self, argument: coordinator)!
    }

    // MARK: - Mypage Flow

    func makeMypageViewController(coordinator: MypageCoordinator) -> MypageViewController {
        container.resolve(MypageViewController.self, argument: coordinator)!
    }

    // MARK: - UseCases

    func resolveAuthUseCase() -> AuthUseCaseProtocol? {
        container.resolve(AuthUseCaseProtocol.self)
    }
}
