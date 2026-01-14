//
//  ArchiveViewController.swift
//  CulLecting
//
//  Created by 김승희 on 4/13/25.
//


import UIKit

import FlexLayout
import Photos
import PinLayout
import RxCocoa
import RxSwift
import Then


final class ArchiveViewController: UIViewController {

    // MARK: Properties
    private let disposeBag = DisposeBag()
    private let viewModel: ArchiveViewModel
    private weak var coordinator: ArchiveCoordinator?

    // Input relays for ViewModel binding
    private let ticketTapped = PublishRelay<Ticket>()
    private let fetchTriggerRelay = PublishRelay<Void>()
    private let imageUploadRelay = PublishRelay<UIImage>()
    private let updateTicketImageRelay = PublishRelay<(ticketId: String, image: UIImage)>()
    private let deleteTicketRelay = PublishRelay<Ticket>()

    // State from ViewModel
    private var isUserLoggedIn = false

    // Image picker state
    private var imagePickCompletion: ((UIImage) -> Void)?
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
        $0.setTitle("+", for: .normal)
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
            imageUploadTrigger: imageUploadRelay.asObservable(),
            updateTicketImageTrigger: updateTicketImageRelay.asObservable(),
            deleteTicketTrigger: deleteTicketRelay.asObservable()
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

        // Floating button tap - handle login check logic in VC
        floatingButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }
                self.handleFloatingButtonTap()
            }
            .disposed(by: disposeBag)

        output.imageUploadCompleted
            .emit(onNext: { [weak self] ticket in
                self?.coordinator?.showTicketDetail(from: ticket)
            })
            .disposed(by: disposeBag)

        // Handle navigation events from ViewModel
        output.navigationEvent
            .emit(onNext: { [weak self] event in
                self?.handleNavigationEvent(event)
            })
            .disposed(by: disposeBag)

        // Track login state from ViewModel
        output.isLoggedIn
            .drive(onNext: { [weak self] isLoggedIn in
                self?.isUserLoggedIn = isLoggedIn
            })
            .disposed(by: disposeBag)
    }

    func handleNavigationEvent(_ event: ArchiveNavigationEvent) {
        switch event {
        case .showTicketDetail(let ticket):
            coordinator?.showTicketDetail(from: ticket)

        case .showDeleteSuccess:
            showAlert(
                title: "삭제 완료",
                message: "티켓이 성공적으로 삭제되었습니다."
            ) { [weak self] in
                self?.coordinator?.popViewController()
            }

        case .showError(let message):
            showAlert(title: "오류", message: message)
        }
    }
}

// MARK: - Add Menu Actions
private extension ArchiveViewController {

    func handleFloatingButtonTap() {
        if !isUserLoggedIn {
            showAlert(
                title: "알림",
                message: "가입하고 내 문화생활을 컬렉팅 해보세요!"
            )
        } else {
            presentAddMenu(actionType: .create)
        }
    }

    func presentAddMenu(actionType: TicketActionType) {
        switch actionType {
        case .create:
            presentAddMenu(
                onSearch: { [weak self] in
                    self?.coordinator?.showSearchTicketInfo(actionType: actionType)
                },
                onPick: { [weak self] in
                    self?.handlePickPhoto(actionType: actionType)
                }
            )

        case .edit(let ticket):
            presentAddMenu(
                onSearch: { [weak self] in
                    self?.coordinator?.showSearchTicketInfo(actionType: actionType)
                },
                onPick: { [weak self] in
                    self?.handlePickPhoto(actionType: actionType)
                },
                onDelete: { [weak self] in
                    self?.deleteTicketRelay.accept(ticket)
                }
            )
        }
    }

    func handlePickPhoto(actionType: TicketActionType) {
        openImagePicker(actionType: actionType) { [weak self] selectedImage in
            switch actionType {
            case .create:
                // Navigate to preview, then upload on confirm
                self?.coordinator?.showPhotoPreview(image: selectedImage) { [weak self] confirmedImage in
                    self?.imageUploadRelay.accept(confirmedImage)
                }
            case .edit(let ticket):
                // Directly update the ticket image
                self?.updateTicketImageRelay.accept((ticketId: ticket.id, image: selectedImage))
            }
        }
    }
}


// MARK: - Image Picker
extension ArchiveViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func openImagePicker(actionType: TicketActionType, completion: @escaping (UIImage) -> Void) {
        imagePickCompletion = completion
        currentActionType = actionType
        checkPhotoLibraryPermission()
    }

    private func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized, .limited:
            showPhotoPicker()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { newStatus in
                DispatchQueue.main.async {
                    if newStatus == .authorized || newStatus == .limited {
                        self.showPhotoPicker()
                    } else {
                        self.presentPermissionDeniedAlert()
                    }
                }
            }
        default:
            presentPermissionDeniedAlert()
        }
    }

    func showPhotoPicker() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }

    private func presentPermissionDeniedAlert() {
        showAlertWithCancel(
            title: "사진 권한 필요",
            message: "앨범에 접근하려면 사진 권한을 허용해주세요.",
            okTitle: "설정으로 이동",
            cancelTitle: "취소",
            okHandler: {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        )
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        if let image = info[.originalImage] as? UIImage {
            imagePickCompletion?(image)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
