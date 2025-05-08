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
    
    // MARK: Properties
    private let disposeBag = DisposeBag()
    private let viewModel: ArchiveViewModel
    private weak var coordinator: ArchiveCoordinator?
    
    private let ticketTapped = PublishRelay<Ticket>()
    private var imagePickCompletion: ((UIImage) -> Void)?
    private let fetchTriggerRelay = PublishRelay<Void>()
    private let imageUploadRelay = PublishRelay<UIImage>()
    private var currentActionType: TicketActionType = .create
    
    // MARK: UI Components
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
    
    private let containerView = UIView()
    private let contentContainerView = UIView()
    private let ticketSegmentView = TicketSegmentView()
    private let analyzeSegmentView = AnalyzeSegmentView()
    
    private let floatingButton = UIButton().then {
        $0.setTitle("＋", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 27, weight: .bold)
        $0.backgroundColor = .grey90
        $0.layer.cornerRadius = 27
    }
    
    // MARK: init
    init(viewModel: ArchiveViewModel, coordinator: ArchiveCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View LifeCycle
    //TODO: 변경사항 반영 메서드 추가
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchTriggerRelay.accept(())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        setupUI()
        bindViewModel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layout()
    }
}

// MARK: - Setup
private extension ArchiveViewController {
    
    func setNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.title = "내 기록"
    }
    
    func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(containerView)
        view.addSubview(floatingButton)
        
        containerView.addSubview(segmentedControl)
        containerView.addSubview(contentContainerView)
        
        contentContainerView.addSubview(ticketSegmentView)
        contentContainerView.addSubview(analyzeSegmentView)
        
        ticketSegmentView.isHidden = false
        analyzeSegmentView.isHidden = true
    }
    
    func layout() {
        containerView.pin
            .top(view.pin.safeArea.top)
            .left()
            .right()
            .bottom(view.pin.safeArea.bottom)
        
        containerView.flex
            .direction(.column)
            .alignItems(.center)
            .define {
                $0.addItem(segmentedControl)
                    .marginTop(12)
                    .width(180)
                    .height(36)
                
                $0.addItem(contentContainerView)
                    .marginTop(20)
                    .width(100%)
                    .grow(1)
            }
        
        containerView.flex.layout()
        
        ticketSegmentView.pin.all()
        analyzeSegmentView.pin.all()
        
        floatingButton.pin
            .bottom(view.pin.safeArea.bottom).marginBottom(20)
            .right(view.pin.safeArea.right).marginRight(20)
            .width(54)
            .height(54)
    }
}

// MARK: - Binding
private extension ArchiveViewController {
    
    func bindViewModel() {
        let fetchTrigger = fetchTriggerRelay
            .asObservable()
            .startWith(())
        
        let segmentChanged = segmentedControl.rx.selectedSegmentIndex.asObservable()
        
        ticketSegmentView.onTicketTapped = { [weak self] ticket in
            self?.ticketTapped.accept(ticket)
        }
        
        let input = ArchiveViewModel.Input(
            fetchTrigger: fetchTrigger,
            segmentChanged: segmentChanged,
            ticketTapped: ticketTapped.asObservable(),
            imageUploadTrigger: imageUploadRelay.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.archivingList
            .drive(onNext: { [weak self] tickets in
                self?.ticketSegmentView.configure(with: tickets)
            })
            .disposed(by: disposeBag)
        
        output.preferenceCard
            .withLatestFrom(output.ticketCount) { (card: $0, count: $1) }
            .drive(onNext: { [weak self] pair in
                guard let self, let card = pair.card else { return }
                self.analyzeSegmentView.configure(with: card, ticketCount: pair.count)
            })
            .disposed(by: disposeBag)
        
        output.isShowingArchiving
            .drive(onNext: { [weak self] isArchiving in
                self?.ticketSegmentView.isHidden = !isArchiving
                self?.analyzeSegmentView.isHidden = isArchiving
                if isArchiving {
                    self?.contentContainerView.bringSubviewToFront(self?.ticketSegmentView ?? UIView())
                } else {
                    self?.contentContainerView.bringSubviewToFront(self?.analyzeSegmentView ?? UIView())
                }
            })
            .disposed(by: disposeBag)
        
        output.selectedTicket
            .emit(onNext: { [weak self] ticket in
                self?.coordinator?.showTicketDetail(from: ticket)
            })
            .disposed(by: disposeBag)
        
        floatingButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }
                if TokenStorage.shared.accessToken == nil {
                    self.showAlert(
                        title: "알림",
                        message: "가입하고 내 문화생활을 컬렉팅 해보세요!"
                    )
                } else {
                    self.coordinator?.presentAddMenu(from: self, actionType: .create)
                }
            }
            .disposed(by: disposeBag)
        
        
        output.imageUploadCompleted
            .emit(onNext: { [weak self] ticket in
                self?.showAlert(
                    title: "티켓 등록 성공!",
                    message: "티켓 상세페이지에서 내용을 수정해보세요."
                )
            })
            .disposed(by: disposeBag)
    }
}


// MARK: - Image Picker
extension ArchiveViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func showPhotoPicker() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    func openImagePicker(actionType: TicketActionType, completion: @escaping (UIImage) -> Void) {
        imagePickCompletion = completion
        currentActionType = actionType
        showPhotoPicker()
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        if let image = info[.originalImage] as? UIImage {
            switch currentActionType {
            case .create:
                coordinator?.uploadTicket(image: image)
                
            case .edit(let ticket):
                coordinator?.updateTicketImage(ticketId: ticket.id, newImage: image)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
