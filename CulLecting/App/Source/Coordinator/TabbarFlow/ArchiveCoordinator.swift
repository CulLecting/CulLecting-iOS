//
//  ArchiveCoordinatorProtocol.swift
//  CulLecting
//
//  Created by 김승희 on 4/23/25.
//


import UIKit

import Swinject


protocol ArchiveCoordinatorProtocol: AnyObject {
    func showAddTicket()
    func editTicketDetail(ticket: Ticket)
}

final class ArchiveCoordinator: CoordinatorProtocol {
    var childCoordinators: [any CoordinatorProtocol] = []
    var navigationController: UINavigationController
    var finishDelegate: (any CoordinatorFinishDelegate)?
    var type: CoordinatorType = .archive
    
    private let injector: Resolver
    private let viewModel: ArchiveViewModel
    weak var parentCoordinator: TabbarCoordinator?
    
    init(injector: Resolver) {
        self.navigationController = UINavigationController()
        self.injector = injector
        self.viewModel = injector.resolve(ArchiveViewModel.self)!
    }

    func start() {
        let archiveVC = ArchiveViewController(viewModel: viewModel, coordinator: self)
        navigationController.setViewControllers([archiveVC], animated: false)
    }
}

extension ArchiveCoordinator: ArchiveCoordinatorProtocol {
    
    func showAddTicket() {
        let addTicketVM = injector.resolve(AddTicketViewModel.self)!
        let addTicketVC = AddTicketViewController(viewModel: addTicketVM)
        navigationController.pushViewController(addTicketVC, animated: true)
    }
    
    func editTicketDetail(ticket: Ticket) {
        let ticketEditVC = TicketEditViewController(ticket: ticket, viewModel: viewModel)
        navigationController.present(ticketEditVC, animated: true)
    }
}
