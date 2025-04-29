//
//  TicketDetailViewController.swift
//  CulLecting
//
//  Created by 김승희 on 4/15/25.
//


import UIKit

import FlexLayout
import PinLayout
import RxCocoa
import RxSwift
import Then


final class TicketDetailViewController: UIViewController {
    
    // MARK: Properties
    private let disposeBag = DisposeBag()
    private let viewModel: TicketDetailViewModel
    private let coordinator: ArchiveCoordinator
    private var ticket: Ticket
    
    // MARK: UI Components
    private lazy var ticketView = TicketView(ticket: ticket)
    private let editButton = UIButton.makeButton(style: .darkButtonActive, title: "내용 수정하기", cornerRadius: 28)
    
    // MARK: Init
    init(viewModel: TicketDetailViewModel, ticket: Ticket, coordinator: ArchiveCoordinator) {
        self.viewModel = viewModel
        self.ticket = ticket
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setNavigationBar()
        bindViewModel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutUI()
    }
}

// MARK: - UI
private extension TicketDetailViewController {
    
    func setUI() {
        view.backgroundColor = .white
        view.addSubview(ticketView)
        view.addSubview(editButton)
    }
    
    func layoutUI() {
        ticketView.pin
            .top(view.pin.safeArea.top + 20)
            .horizontally(20)
            .height(400)
        
        editButton.pin
            .below(of: ticketView, aligned: .center)
            .marginTop(20)
            .width(120)
            .height(44)
    }
    
    func setNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis"),
            style: .plain,
            target: self,
            action: #selector(optionsButtonTapped)
        )
    }
    
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func optionsButtonTapped() {
        coordinator.presentAddMenu(from: self, actionType: .edit(ticket: ticket))
    }
    
    func presentShareSheet() {
        let items: [Any] = ["\(ticket.title)\n\(ticket.description)"]
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(activityVC, animated: true)
    }
}

// MARK: - Binding
private extension TicketDetailViewController {
    
    func bindViewModel() {
        let input = TicketDetailViewModel.Input(
            editTrigger: editButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.editTapped
            .withUnretained(self)
            .bind(onNext: { owner, _ in
                owner.coordinator.editTicketDetail(ticket: owner.ticket) { updatedTicket in
                    owner.viewModel.updateTicket(updatedTicket)
                }
            })
            .disposed(by: disposeBag)
        
        output.ticketUpdated
            .withUnretained(self)
            .bind(onNext: { owner, updatedTicket in
                owner.ticket = updatedTicket
                owner.ticketView.update(ticket: updatedTicket)
            })
            .disposed(by: disposeBag)
    }
}
