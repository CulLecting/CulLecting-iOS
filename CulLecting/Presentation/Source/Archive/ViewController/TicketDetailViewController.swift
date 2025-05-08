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
    private var isFlipped = false

    // MARK: UI Components
    private var ticketContainerView = UIView()
    private lazy var ticketFrontView = TicketFrontView(ticket: ticket)
    private lazy var ticketBackView = TicketBackView(ticket: ticket)
    private let flipIcon = UIImageView(image: UIImage.rotateButton).then {
        $0.isUserInteractionEnabled = true
    }
    private let editButton = UIButton.makeButton(style: .darkButtonActive, title: "내용 수정하기", cornerRadius: 28)

    // MARK: init
    init(viewModel: TicketDetailViewModel, ticket: Ticket, coordinator: ArchiveCoordinator) {
        self.viewModel = viewModel
        self.ticket = ticket
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: LifeCycle
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

    private func setUI() {
        view.backgroundColor = .white
        view.addSubview(ticketContainerView)
        view.addSubview(flipIcon)
        view.addSubview(editButton)
        
        [ticketFrontView, ticketBackView].forEach {ticketContainerView.addSubview($0)}
        
        ticketBackView.isHidden = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(flipCard))
        ticketContainerView.addGestureRecognizer(tapGesture)
    }

    func layoutUI() {
        ticketContainerView.pin
            .top(view.pin.safeArea.top + 20)
            .horizontally(20)
            .height(60%)
        
        ticketFrontView.frame = ticketContainerView.bounds
        ticketBackView.frame = ticketContainerView.bounds
        
        flipIcon.pin
            .below(of: ticketFrontView)
            .marginTop(12)
            .hCenter()
            .width(32)
            .height(48)
        
        editButton.pin
            .below(of: flipIcon)
            .marginTop(20)
            .hCenter()
            .width(90%)
            .height(56)
    }

    func setNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        ).then { $0.tintColor = .grey90 }

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis"),
            style: .plain,
            target: self,
            action: #selector(optionsButtonTapped)
        ).then { $0.tintColor = .grey90 }
    }

    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func optionsButtonTapped() {
        coordinator.presentAddMenu(from: self, actionType: .edit(ticket: ticket))
    }

    @objc private func flipCard() {
        print("flipCard 실행됨")
        let fromView = isFlipped ? ticketBackView : ticketFrontView
        let toView = isFlipped ? ticketFrontView : ticketBackView

        UIView.transition(from: fromView,
                          to: toView,
                          duration: 0.6,
                          options: [.transitionFlipFromRight, .showHideTransitionViews],
                          completion: nil)

        isFlipped.toggle()
    }
}

// MARK: - ViewModel Binding
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
            .observe(on: MainScheduler.instance)
            .bind(onNext: { [weak self] updatedTicket in
                guard let self else { return }
                self.ticket = updatedTicket
                self.ticketFrontView.configure(with: updatedTicket)
                self.ticketBackView.configure(with: updatedTicket)
            })
            .disposed(by: disposeBag)
    }
}
