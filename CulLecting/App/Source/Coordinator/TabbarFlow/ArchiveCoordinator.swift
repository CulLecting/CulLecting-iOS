//
//  ArchiveCoordinator.swift
//  CulLecting
//
//  Created by 김승희 on 4/23/25.
//


import UIKit

import RxCocoa
import RxSwift
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
    let viewModel: ArchiveViewModel
    private let disposeBag = DisposeBag()
    
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


//MARK: flow에 따른 메서드들
extension ArchiveCoordinator {
    
    func presentAddMenu(from viewController: UIViewController, actionType: TicketActionType) {
        viewController.presentAddMenu(
            onSearch: { [weak self] in self?.showSearchTicketInfo(actionType: actionType) },
            onPick: { [weak self] in self?.pickPhotoFromLibrary(actionType: actionType) }
        )
    }
    
    func uploadTicket(image: UIImage) {
        let useCase = injector.resolve(ArchivingUseCase.self)!
        
        useCase.uploadArchiveImg(image: image)
            .flatMap { id in
                useCase.fetchTicket(id: id)
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] ticket in
                self?.showTicketDetail(from: ticket)
            }, onFailure: { error in
                print("티켓 업로드 실패: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
    }
    
    func showSearchTicketInfo(actionType: TicketActionType) {
        let searchVM = injector.resolve(SearchCulturalInfoViewModel.self, argument: actionType)!
        let searchVC = SearchCulutralInfoViewController(viewModel: searchVM, coordinator: self, actionType: .create)
        navigationController.pushViewController(searchVC, animated: true)
    }
    
    func pickPhotoFromLibrary(actionType: TicketActionType) {
        guard let archiveVC = navigationController.viewControllers.first as? ArchiveViewController else { return }
        archiveVC.openImagePicker { [weak self] selectedImage in
            switch actionType {
            case .create:
                self?.showPhotoPreview(image: selectedImage)
            case .edit(let ticket):
                self?.updateTicketImage(ticketId: ticket.id, newImage: selectedImage)
            }
        }
    }
    
    func showPhotoPreview(image: UIImage) {
        let previewVC = PhotoPreviewViewController(image: image) { [weak self] selectedImage in
            self?.uploadTicket(image: selectedImage)
        }
        navigationController.pushViewController(previewVC, animated: true)
    }
    
    func updateTicketImage(ticketId: String, newImage: UIImage) {
        let useCase = injector.resolve(ArchivingUseCase.self)!
        
        useCase.updateImage(id: ticketId, image: newImage)
            .andThen(useCase.fetchTicket(id: ticketId))
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] updatedTicket in
                self?.showTicketDetail(from: updatedTicket)
            }, onFailure: { error in
                print("티켓 업데이트 실패: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
    }
    
    func showTicketDetail(from ticket: Ticket) {
        let detailVM = injector.resolve(TicketDetailViewModel.self)!
        let detailVC = TicketDetailViewController(viewModel: detailVM, ticket: ticket, coordinator: self)
        navigationController.pushViewController(detailVC, animated: true)
    }
    
    func editTicketDetail(ticket: Ticket, onUpdated: @escaping (Ticket) -> Void) {
        let viewModel = TicketEditViewModel(
            useCase: injector.resolve(ArchivingUseCase.self)!,
            ticketId: ticket.id
        )
        let editVC = TicketEditViewController(ticket: ticket, viewModel: viewModel)
        
        editVC.onSaveCompleted = { updatedTicket in
            onUpdated(updatedTicket)
        }
        
        let nav = UINavigationController(rootViewController: editVC)
        nav.modalPresentationStyle = .automatic
        navigationController.present(nav, animated: true)
    }
}
