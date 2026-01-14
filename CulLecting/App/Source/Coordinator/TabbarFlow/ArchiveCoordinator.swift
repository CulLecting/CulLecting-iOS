//
//  ArchiveCoordinator.swift
//  CulLecting
//
//  Created by 김승희 on 4/23/25.
//


import UIKit

import Swinject


enum TicketActionType {
    case create
    case edit(ticket: Ticket)
}

final class ArchiveCoordinator: CoordinatorProtocol {
    var childCoordinators: [any CoordinatorProtocol] = []
    var navigationController: UINavigationController
    weak var parentCoordinator: TabbarCoordinator?
    var finishDelegate: (any CoordinatorFinishDelegate)?
    var type: CoordinatorType = .archive

    let injector: Resolver

    // State for modal edit flow
    private var presentedEditNavController: UINavigationController?
    private var onTicketUpdated: ((Ticket) -> Void)?

    init(injector: Resolver) {
        self.navigationController = UINavigationController()
        self.injector = injector
    }

    func start() {
        let viewModel = injector.resolve(ArchiveViewModel.self)!
        let archiveVC = ArchiveViewController(viewModel: viewModel, coordinator: self)
        navigationController.setViewControllers([archiveVC], animated: false)
    }
}


// MARK: - Navigation Methods (Pure Navigation Only)
extension ArchiveCoordinator {

    func showSearchTicketInfo(actionType: TicketActionType) {
        let searchVM = injector.resolve(SearchCulturalInfoViewModel.self, argument: actionType)!
        let searchVC = SearchCulutralInfoViewController(viewModel: searchVM, coordinator: self, actionType: .create)
        navigationController.pushViewController(searchVC, animated: true)
    }

    func showPhotoPreview(image: UIImage, onConfirm: @escaping (UIImage) -> Void) {
        let previewVC = PhotoPreviewViewController(image: image, onConfirm: onConfirm)
        navigationController.pushViewController(previewVC, animated: true)
    }

    func showTicketDetail(from ticket: Ticket) {
        let detailVM = injector.resolve(TicketDetailViewModel.self)!
        let detailVC = TicketDetailViewController(viewModel: detailVM, ticket: ticket, coordinator: self)
        navigationController.pushViewController(detailVC, animated: true)
    }

    func editTicketDetail(ticket: Ticket, onUpdated: @escaping (Ticket) -> Void) {
        let viewModel = TicketEditViewModel(
            useCase: injector.resolve(ArchivingUseCase.self)!,
            ticket: ticket
        )

        let editVC = TicketEditViewController(ticket: ticket, viewModel: viewModel)
        editVC.delegate = self

        let nav = UINavigationController(rootViewController: editVC)
        nav.modalPresentationStyle = .automatic

        // Store state for delegate callbacks
        self.presentedEditNavController = nav
        self.onTicketUpdated = onUpdated

        navigationController.present(nav, animated: true)
    }

    func dismissEditModal() {
        presentedEditNavController?.dismiss(animated: true)
        presentedEditNavController = nil
        onTicketUpdated = nil
    }

    func popViewController() {
        navigationController.popViewController(animated: true)
    }
}

// MARK: - TicketEditViewControllerDelegate
extension ArchiveCoordinator: TicketEditViewControllerDelegate {

    func ticketEditDidComplete(with updatedTicket: Ticket) {
        onTicketUpdated?(updatedTicket)
        dismissEditModal()
    }

    func ticketEditDidFail(with error: Error) {
        // Keep modal open, error is already logged in VC
        // Could show alert here if needed
    }
}
