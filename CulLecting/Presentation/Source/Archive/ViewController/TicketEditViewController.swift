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


final class TicketEditViewController: UIViewController {
    
    // MARK: Properties
    private var ticket: Ticket
    private let viewModel: TicketEditViewModel
    private let disposeBag = DisposeBag()
    
    var onSaveCompleted: ((Ticket) -> Void)?
    private let selectedImageRelay = BehaviorRelay<UIImage?>(value: nil)
    
    //MARK: UI Components
    private let rootContainer = UIScrollView()
    private let contentContainer = UIView()
    
    private let titleLabel = UILabel().then {
        $0.text = "어떤 행사였나요?"
        $0.font = .systemFont(ofSize: 16, weight: .semibold)
    }
    
    private let titleTextField = UITextField.makeTextField(style: .defaultStyle, placeholderText: "행사 제목을 입력하세요")
    
    private let categoryLabel = UILabel().then {
        $0.text = "문화 카테고리"
        $0.font = .systemFont(ofSize: 16, weight: .semibold)
    }
    
    private let categoryButton = UIButton().then {
        $0.setTitle("카테고리 선택", for: .normal)
        $0.setTitleColor(.grey70, for: .normal)
        $0.titleLabel?.font = .fontPretendard(style: .body14R)
        $0.backgroundColor = .grey20
        $0.layer.cornerRadius = 10
        $0.contentHorizontalAlignment = .left
    }
    
    private let dateLabel = UILabel().then {
        $0.text = "언제 다녀오셨나요?"
        $0.font = .systemFont(ofSize: 16, weight: .semibold)
    }
    
    private let dateSelectButton = UIButton().then {
        $0.setTitle("날짜 선택", for: .normal)
        $0.setTitleColor(.grey70, for: .normal)
        $0.titleLabel?.font = .fontPretendard(style: .body14R)
        $0.backgroundColor = .grey20
        $0.layer.cornerRadius = 10
        $0.contentHorizontalAlignment = .left
    }
    
    private let datePicker = UIDatePicker().then {
        $0.datePickerMode = .date
        $0.preferredDatePickerStyle = .wheels
        $0.locale = Locale(identifier: "ko_KR")
        $0.isHidden = true
    }
    
    private let backTextLabel = UILabel().then {
        $0.text = "뒷면 텍스트"
        $0.font = .systemFont(ofSize: 16, weight: .semibold)
    }
    
    private let backTextView = UITextView().then {
        $0.font = .systemFont(ofSize: 14)
        $0.layer.cornerRadius = 8
        $0.layer.borderColor = UIColor.lightGray.cgColor
        $0.layer.borderWidth = 1
        $0.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }
    
    private let saveButton = UIButton.makeButton(style: .darkButtonActive, title: "수정하기", cornerRadius: 28)
    
    // MARK: Init
    init(ticket: Ticket, viewModel: TicketEditViewModel) {
        self.ticket = ticket
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        setupData()
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

//MARK: -Bind
private extension TicketEditViewController {
    func bindViewModel() {
        let titleInput = titleTextField.rx.text.orEmpty.asObservable()
        let descriptionInput = backTextView.rx.text.orEmpty.asObservable()
        let dateInput = datePicker.rx.date
            .map { DateFormatter().then { $0.dateFormat = "yyyy-MM-dd" }.string(from: $0) }
            .asObservable()
        let categoryInput = categoryButton.rx.tap
            .map { [weak self] in self?.categoryButton.title(for: .normal) ?? "" }
            .asObservable()
//        let imageInput = selectedImageRelay.asObservable()
        let saveTrigger = saveButton.rx.tap.asObservable()

        let input = TicketEditViewModel.Input(
            titleInput: titleInput,
            descriptionInput: descriptionInput,
            dateInput: dateInput,
            categoryInput: categoryInput,
            saveTrigger: saveTrigger
        )
        
        let output = viewModel.transform(input: input)
        
        output.saveCompleted
            .drive(onNext: { [weak self] in
                guard let self else { return }
                self.onSaveCompleted?(self.ticket)
                self.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        output.saveFailed
            .drive(onNext: { error in
                print("수정 실패: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
        
        output.enableSave
            .drive(saveButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
}

    
    //MARK: -Setup
private extension TicketEditViewController {
    private func setupUI() {
        view.addSubview(rootContainer)
        rootContainer.addSubview(contentContainer)
        
        contentContainer.flex
            .paddingHorizontal(20)
            .paddingTop(24)
            .define {
                $0.addItem(titleLabel).marginBottom(8)
                $0.addItem(titleTextField).height(44)
                
                $0.addItem(categoryLabel).marginTop(16).marginBottom(8)
                $0.addItem(categoryButton).height(44)
                
                $0.addItem(dateLabel).marginTop(16).marginBottom(8)
                $0.addItem(dateSelectButton).height(44)
                
                $0.addItem(datePicker).marginTop(8)
                
                $0.addItem(backTextLabel).marginTop(16).marginBottom(8)
                $0.addItem(backTextView).height(120)
                
                $0.addItem(saveButton).marginTop(32).height(56)
            }
    }

    func layoutUI() {
        rootContainer.pin.all(view.pin.safeArea)
        contentContainer.pin.width(of: rootContainer).sizeToFit(.width)
        rootContainer.contentSize = contentContainer.frame.size
    }
    
    func setupData() {
        titleTextField.text = ticket.title
        backTextView.text = ticket.description
        categoryButton.setTitle(ticket.category, for: .normal)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: ticket.date) {
            datePicker.date = date
            updateDateButtonTitle(with: date)
        }
    }
    
    func setupActions() {
        dateSelectButton.addAction(UIAction { [weak self] _ in
            self?.datePicker.isHidden.toggle()
        }, for: .touchUpInside)
        
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        
        categoryButton.addAction(UIAction { [weak self] _ in
            self?.presentCategoryPicker()
        }, for: .touchUpInside)
    }
    
    @objc func dateChanged() {
        updateDateButtonTitle(with: datePicker.date)
    }
    
    func updateDateButtonTitle(with date: Date) {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "ko_KR")
        let dateString = formatter.string(from: date)
        dateSelectButton.setTitle(dateString, for: .normal)
    }
    
    private func presentCategoryPicker() {
        let alert = UIAlertController(title: "카테고리 선택", message: nil, preferredStyle: .actionSheet)
        
        Category.allCases.forEach { category in
            let action = UIAlertAction(title: category.rawValue, style: .default) { [weak self] _ in
                self?.categoryButton.setTitle(category.rawValue, for: .normal)
            }
            alert.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
}
