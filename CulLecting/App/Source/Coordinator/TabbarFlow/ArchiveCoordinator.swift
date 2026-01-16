//
//  ArchiveCoordinator.swift
//  CulLecting
//
//  Created by 김승희 on 4/23/25.
//

import UIKit

enum TicketActionType {
    case create
    case edit(ticket: Ticket)
}

final class ArchiveCoordinator: CoordinatorProtocol {

    var childCoordinators: [CoordinatorProtocol] = []
    var navigationController: UINavigationController
    var parentCoordinator: CoordinatorProtocol?

    private let container: AppDIContainer
    private var presentedEditNavController: UINavigationController?
    private var onTicketUpdated: ((Ticket) -> Void)?

    init(container: AppDIContainer) {
        self.container = container
        self.navigationController = UINavigationController()
    }

    func start() {
        let archiveVC = container.makeArchiveViewController(coordinator: self)
        navigationController.setViewControllers([archiveVC], animated: false)
    }

    // MARK: - Navigation

    func showSearchTicketInfo(actionType: TicketActionType) {
        let searchVC = container.makeSearchCulturalInfoViewController(coordinator: self, actionType: actionType)
        navigationController.pushViewController(searchVC, animated: true)
    }

    func showPhotoPreview(image: UIImage, onConfirm: @escaping (UIImage) -> Void) {
        let previewVC = container.makePhotoPreviewViewController(image: image, onConfirm: onConfirm)
        navigationController.pushViewController(previewVC, animated: true)
    }

    func showTicketDetail(from ticket: Ticket) {
        let detailVC = container.makeTicketDetailViewController(coordinator: self, ticket: ticket)
        navigationController.pushViewController(detailVC, animated: true)
    }

    func editTicketDetail(ticket: Ticket, onUpdated: @escaping (Ticket) -> Void) {
        let editVC = container.makeTicketEditViewController(ticket: ticket)
        editVC.delegate = self

        let nav = UINavigationController(rootViewController: editVC)
        nav.modalPresentationStyle = .automatic

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
    }
}
