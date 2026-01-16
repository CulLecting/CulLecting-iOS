//
//  TicketEditViewController.swift
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


protocol TicketEditViewControllerDelegate: AnyObject {
    func ticketEditDidComplete(with updatedTicket: Ticket)
    func ticketEditDidFail(with error: Error)
}

final class TicketEditViewController: UIViewController {

    // MARK: Properties
    private var ticket: Ticket
    private let viewModel: TicketEditViewModel
    private let disposeBag = DisposeBag()

    weak var delegate: TicketEditViewControllerDelegate?
    private let selectedImageRelay = BehaviorRelay<UIImage?>(value: nil)
    private let selectedDateRelay: BehaviorRelay<String>
    private let selectedCategoryRelay: BehaviorRelay<String>
    
    // MARK: UI Components
    private let rootContainer = UIScrollView()
    private let contentContainer = UIView()
    
    private let titleLabel = UILabel().then {
        $0.text = "어떤 행사였나요?"
        $0.font = .fontPretendard(style: .caption12M)
        $0.textColor = .grey80
    }
    
    private let titleTextField = UITextField.makeTextField(style: .defaultStyle, placeholderText: "행사 제목을 입력하세요").then {
        $0.heightAnchor.constraint(equalToConstant: 56).isActive = true
        $0.backgroundColor = .grey10
        $0.layer.cornerRadius = 17
    }
    
    private let categoryLabel = UILabel().then {
        $0.text = "문화 카테고리"
        $0.font = .fontPretendard(style: .caption12M)
        $0.textColor = .grey80
    }
    
    private let categoryButton = UIButton().then {
        $0.applyPickerStyle(title: "카테고리 선택")
    }
    
    private let dateLabel = UILabel().then {
        $0.text = "언제 다녀오셨나요?"
        $0.font = .fontPretendard(style: .caption12M)
        $0.textColor = .grey80
    }
    
    private let dateSelectButton = UIButton().then {
        $0.applyPickerStyle(title: "날짜 선택")
    }
    
    private let backTextLabel = UILabel().then {
        $0.text = "어떤 기억이 남았나요?"
        $0.font = .systemFont(ofSize: 16, weight: .semibold)
    }
    
    private let backTextView = UITextView().then {
        $0.font = .fontPretendard(style: .body14M)
        $0.textColor = .grey90
        $0.backgroundColor = .grey10
        $0.layer.cornerRadius = 17
        $0.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        $0.isScrollEnabled = false
    }
    
    private let saveButton = UIButton.makeButton(style: .darkButtonActive, title: "수정하기", cornerRadius: 28)
    
    
    // MARK: init
    init(ticket: Ticket, viewModel: TicketEditViewModel) {
        self.ticket = ticket
        self.viewModel = viewModel
        
        self.selectedDateRelay = BehaviorRelay(value: ticket.date)
        self.selectedCategoryRelay = BehaviorRelay(value: ticket.category)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        setupData()
        setupActions()
        bindViewModel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        rootContainer.pin.all(view.pin.safeArea)
        contentContainer.pin.width(of: rootContainer).layout()
        contentContainer.flex.layout(mode: .adjustHeight)
        rootContainer.contentSize = contentContainer.frame.size
    }
}


// MARK: - Bind
private extension TicketEditViewController {
    func bindViewModel() {
        let titleInput = titleTextField.rx.text.orEmpty.asObservable()
        let descriptionInput = backTextView.rx.text.orEmpty.asObservable()

        let saveTrigger = saveButton.rx.tap.asObservable()

        let input = TicketEditViewModel.Input(
            titleInput: titleInput,
            descriptionInput: descriptionInput,
            dateInput: selectedDateRelay.asObservable(),
            categoryInput: selectedCategoryRelay.asObservable(),
            saveTrigger: saveTrigger
        )

        let output = viewModel.transform(input: input)

        output.updatedTicket
            .drive(onNext: { [weak self] updatedTicket in
                self?.delegate?.ticketEditDidComplete(with: updatedTicket)
            })
            .disposed(by: disposeBag)

        output.saveFailed
            .drive(onNext: { [weak self] error in
                print("수정 실패: \(error.localizedDescription)")
                self?.delegate?.ticketEditDidFail(with: error)
            })
            .disposed(by: disposeBag)
    }
}


// MARK: - Setup
private extension TicketEditViewController {
    func setupUI() {
        view.addSubview(rootContainer)
        rootContainer.addSubview(contentContainer)
        
        contentContainer.flex
            .paddingHorizontal(20)
            .paddingTop(24)
            .define {
                $0.addItem(titleLabel).marginBottom(8)
                $0.addItem(titleTextField).height(56)
                
                $0.addItem(categoryLabel).marginTop(28).marginBottom(8)
                $0.addItem(categoryButton).height(56)
                
                $0.addItem(dateLabel).marginTop(28).marginBottom(8)
                $0.addItem(dateSelectButton).height(56)
                
                $0.addItem(backTextLabel).marginTop(28).marginBottom(8)
                $0.addItem(backTextView).height(220)
                
                $0.addItem(saveButton).marginTop(32).height(56)
            }
    }
    
    func setupData() {
        titleTextField.text = ticket.title
        backTextView.text = ticket.description
        categoryButton.setTitle(ticket.category, for: .normal)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: ticket.date) {
            updateDateButtonTitle(with: date)
        }
    }
    
    func setupActions() {
        dateSelectButton.addAction(UIAction { [weak self] _ in
            self?.presentDatePickerModal()
        }, for: .touchUpInside)
        
        categoryButton.addAction(UIAction { [weak self] _ in
            self?.presentCategoryModal()
        }, for: .touchUpInside)
    }
    
    private func presentDatePickerModal() {
        let vc = DatePickerBottomSheet()
        vc.onDateSelected = { [weak self] date in
            guard let self else { return }
            self.updateDateButtonTitle(with: date)

            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            self.selectedDateRelay.accept(formatter.string(from: date))
        }
        
        let nav = UINavigationController(rootViewController: vc)
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        
        present(nav, animated: true)
    }
    
    private func presentCategoryModal() {
        let vc = CategoryBottomSheet()
        vc.onCategorySelected = { [weak self] category in
            guard let self else { return }
            self.categoryButton.setTitle(category, for: .normal)
            self.selectedCategoryRelay.accept(category)
        }

        let nav = UINavigationController(rootViewController: vc)
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }

        present(nav, animated: true)
    }
    
    func updateDateButtonTitle(with date: Date) {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "ko_KR")
        let dateString = formatter.string(from: date)
        dateSelectButton.setTitle(dateString, for: .normal)
    }
}
