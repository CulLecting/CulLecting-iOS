//
//  ArchiveViewController.swift
//  CulLecting
//
//  Created by 김승희 on 4/13/25.
//


import UIKit

import FlexLayout
import PinLayout
import RxCocoa
import RxSwift
import Then


final class ArchiveViewController: UIViewController {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let viewModel: ArchiveViewModel
    //private weak var coordinator: ArchiveCoordinatorProtocol?
    
    // MARK: - UI Components
    private let segmentedControl = UISegmentedControl(items: ["내 기록", "취향 카드"]).then {
        $0.selectedSegmentIndex = 0
        $0.backgroundColor = .grey20
        $0.selectedSegmentTintColor = .grey90
        $0.setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            .font: UIFont.fontPretendard(style: .body14M)
        ], for: .selected)
        $0.setTitleTextAttributes([
            .foregroundColor: UIColor.grey70,
            .font: UIFont.fontPretendard(style: .body14M)
        ], for: .normal)
        $0.layer.cornerRadius = 18
        $0.clipsToBounds = true
    }
    
    private let contentContainerView = UIView()
    private let ticketSegmentView = TicketSegmentView()
    private let analyzeSegmentView = AnalyzeSegmentView()
    
    private let floatingButton = UIButton().then {
        $0.setTitle("＋", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 27, weight: .bold)
        $0.backgroundColor = .grey90
        $0.layer.borderWidth = 0
        $0.layer.cornerRadius = 27
    }

    // MARK: - Init
    init(viewModel: ArchiveViewModel) {
        self.viewModel = viewModel
        //self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        setupUI()
        setAction()
        bindViewModel()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutUI()
    }

    // MARK: - ViewModel Binding
    private func bindViewModel() {
        viewModel.archivingList
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] tickets in
                self?.ticketSegmentView.configure(with: tickets)
            })
            .disposed(by: disposeBag)

        viewModel.preferenceCard
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] card in
                guard let card else { return }
                self?.analyzeSegmentView.configure(with: card)
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Setup
    private func setNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.title = "내 기록"
    }

    private func setAction() {
        let floatingButtonAction = UIAction { [weak self] _ in
            self?.showAddTicket()
        }
        floatingButton.addAction(floatingButtonAction, for: .touchUpInside)

        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
    }
    
    func showAddTicket() {
        let useCase = ArchivingUseCase(repository: ArchivingRepository())
        let viewModel = AddTicketViewModel(useCase: useCase)
        let addTicketVC = AddTicketViewController(viewModel: viewModel)
        navigationController?.pushViewController(addTicketVC, animated: true)
    }

    @objc private func segmentChanged() {
        let isTicket = segmentedControl.selectedSegmentIndex == 0
        ticketSegmentView.isHidden = !isTicket
        analyzeSegmentView.isHidden = isTicket

        if isTicket {
            contentContainerView.bringSubviewToFront(ticketSegmentView)
        } else {
            contentContainerView.bringSubviewToFront(analyzeSegmentView)
        }
    }

    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(segmentedControl)
        view.addSubview(contentContainerView)
        view.addSubview(floatingButton)

        contentContainerView.addSubview(ticketSegmentView)
        contentContainerView.addSubview(analyzeSegmentView)

        // 초기 표시
        contentContainerView.bringSubviewToFront(ticketSegmentView)
        analyzeSegmentView.isHidden = true
    }

    private func layoutUI() {
        segmentedControl.pin
            .top(view.pin.safeArea.top + 12)
            .hCenter()
            .width(180)
            .height(36)

        contentContainerView.pin
            .below(of: segmentedControl)
            .marginTop(20)
            .horizontally()
            .bottom(view.pin.safeArea.bottom)

        ticketSegmentView.pin.all()
        analyzeSegmentView.pin.all()

        floatingButton.pin
            .bottom(view.pin.safeArea.bottom + 20)
            .right(20)
            .width(54)
            .height(54)
    }
}
