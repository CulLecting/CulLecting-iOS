//
//  ArchiveAssembly.swift
//  CulLecting
//
//  Created by 김승희 on 4/7/25.
//

import UIKit

import Swinject

struct ArchiveAssembly: Assembly {

    func assemble(container: Container) {
        // Repository
        container.register(ArchivingRepository.self) { _ in
            ArchivingRepository()
        }

        // UseCase
        container.register(ArchivingUseCase.self) { r in
            let repository = r.resolve(ArchivingRepository.self)!
            return ArchivingUseCase(repository: repository)
        }

        // ViewModel
        container.register(ArchiveViewModel.self) { r in
            let useCase = r.resolve(ArchivingUseCase.self)!
            let authUseCase = r.resolve(AuthUseCaseProtocol.self)!
            return ArchiveViewModel(useCase: useCase, authUseCase: authUseCase)
        }

        container.register(SearchCulturalInfoViewModel.self) { (r, actionType: TicketActionType) in
            guard let culturalRepo = r.resolve(CulturalRepositoryProtocol.self),
                  let archivingUseCase = r.resolve(ArchivingUseCase.self) else {
                fatalError("Dependencies not resolved")
            }
            return SearchCulturalInfoViewModel(
                culturalRepository: culturalRepo,
                archivingUseCase: archivingUseCase,
                actionType: actionType
            )
        }

        container.register(TicketEditViewModel.self) { (r, ticket: Ticket) in
            let useCase = r.resolve(ArchivingUseCase.self)!
            return TicketEditViewModel(useCase: useCase, ticket: ticket)
        }

        container.register(TicketDetailViewModel.self) { r in
            let useCase = r.resolve(ArchivingUseCase.self)!
            return TicketDetailViewModel(useCase: useCase)
        }

        // ViewController
        container.register(ArchiveViewController.self) { (r, coordinator: ArchiveCoordinator) in
            let viewModel = r.resolve(ArchiveViewModel.self)!
            return ArchiveViewController(viewModel: viewModel, coordinator: coordinator)
        }

        container.register(SearchCulutralInfoViewController.self) { (r, coordinator: ArchiveCoordinator, actionType: TicketActionType) in
            let viewModel = r.resolve(SearchCulturalInfoViewModel.self, argument: actionType)!
            return SearchCulutralInfoViewController(viewModel: viewModel, coordinator: coordinator, actionType: actionType)
        }

        container.register(PhotoPreviewViewController.self) { (r, image: UIImage, onConfirm: @escaping (UIImage) -> Void) in
            return PhotoPreviewViewController(image: image, onConfirm: onConfirm)
        }

        container.register(TicketDetailViewController.self) { (r, coordinator: ArchiveCoordinator, ticket: Ticket) in
            let viewModel = r.resolve(TicketDetailViewModel.self)!
            return TicketDetailViewController(viewModel: viewModel, ticket: ticket, coordinator: coordinator)
        }

        container.register(TicketEditViewController.self) { (r, ticket: Ticket) in
            let useCase = r.resolve(ArchivingUseCase.self)!
            let viewModel = TicketEditViewModel(useCase: useCase, ticket: ticket)
            return TicketEditViewController(ticket: ticket, viewModel: viewModel)
        }
    }
}
