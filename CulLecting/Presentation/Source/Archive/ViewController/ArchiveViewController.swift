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
    
    private var imagePickCompletion: ((UIImage) -> Void)?
    
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
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        setUI()
        bindViewModel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setLayout()
    }
}

// MARK: - Setup
private extension ArchiveViewController {
    
    func setNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.title = "내 기록"
    }
    
    func setUI() {
        view.backgroundColor = .white
        view.addSubview(segmentedControl)
        view.addSubview(contentContainerView)
        view.addSubview(floatingButton)

        contentContainerView.addSubview(ticketSegmentView)
        contentContainerView.addSubview(analyzeSegmentView)

        contentContainerView.bringSubviewToFront(ticketSegmentView)
        analyzeSegmentView.isHidden = true
    }
    
    func setLayout() {
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
            .bottom(view.pin.safeArea.bottom).marginBottom(20)
            .right(view.pin.safeArea.right).marginRight(20)
            .width(54)
            .height(54)
    }
}

// MARK: - Binding
private extension ArchiveViewController {
    
    func bindViewModel() {
        print("bindVM 호출")
        // Input
        let fetchTrigger = Observable.just(())
        let segmentChanged = segmentedControl.rx.selectedSegmentIndex.asObservable()
        
        let input = ArchiveViewModel.Input(
            fetchTrigger: fetchTrigger,
            segmentChanged: segmentChanged
        )
        
        // Output
        let output = viewModel.transform(input: input)
        
        output.archivingList
            .do(onNext: { ticket in
                print("archivingList 수신: \(ticket.count)개")
            })
            .drive(onNext: { [weak self] tickets in
                self?.ticketSegmentView.configure(with: tickets)
            })
            .disposed(by: disposeBag)
        
        output.preferenceCard
            .do(onNext: { card in
                print("preferenceCard 수신: \(String(describing: card))개")
            })
            .drive(onNext: { [weak self] card in
                guard let card else { return }
                self?.analyzeSegmentView.configure(with: card)
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
        
        floatingButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                self.coordinator?.presentAddMenu(from: self, actionType: .create)
            }
            .disposed(by: disposeBag)
    }
}

//MARK: 기타 메서드
private extension ArchiveViewController {
    
    func showPhotoPicker() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
}


//MARK: -ImagePicker
extension ArchiveViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func openImagePicker(completion: @escaping (UIImage) -> Void) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.completionHandler = completion
        present(picker, animated: true)
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
