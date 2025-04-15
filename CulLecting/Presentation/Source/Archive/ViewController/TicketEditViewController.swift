//
//  TicketEditViewController.swift
//  CulLecting
//
//  Created by 김승희 on 4/15/25.
//

import UIKit
import FlexLayout
import PinLayout
import Then

final class TicketEditViewController: UIViewController {

    // MARK: - Properties
    private var ticket: Ticket
    var onSave: ((Ticket) -> Void)?

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
        $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
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
        $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
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

    // MARK: - Init
    init(ticket: Ticket) {
        self.ticket = ticket
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        setupData()
        setupActions()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        rootContainer.pin.all(view.pin.safeArea)
        contentContainer.pin.width(of: rootContainer).sizeToFit(.width)
        rootContainer.contentSize = contentContainer.frame.size
    }

    // MARK: - Setup
    private func setupUI() {
        view.addSubview(rootContainer)
        rootContainer.addSubview(contentContainer)

        contentContainer.flex
            .padding(20)
            .define {
                $0.addItem(titleLabel)
                $0.addItem(titleTextField).marginTop(8).height(44)
                $0.addItem(categoryLabel).marginTop(20)
                $0.addItem(categoryButton).marginTop(8).height(44)
                $0.addItem(dateLabel).marginTop(20)
                $0.addItem(dateSelectButton).marginTop(8).height(44)
                $0.addItem(datePicker).marginTop(8)
                $0.addItem(backTextLabel).marginTop(20)
                $0.addItem(backTextView).marginTop(8).height(120)
                $0.addItem(saveButton).marginTop(30).height(56)
            }
    }

    private func setupData() {
        titleTextField.text = ""
        datePicker.date = ticket.attendAt
        backTextView.text = ticket.backText
        updateDateButtonTitle(with: ticket.attendAt)
    }

    private func setupActions() {
        dateSelectButton.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            self.datePicker.isHidden.toggle()
        }, for: .touchUpInside)

        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)

        saveButton.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            let updatedTicket = Ticket(
                id: ticket.id,
                attendAt: datePicker.date,
                poster: ticket.poster,
                averageColorHex: ticket.averageColorHex,
                backText: backTextView.text
            )
            self.onSave?(updatedTicket)
            self.dismiss(animated: true)
        }, for: .touchUpInside)
    }

    @objc private func dateChanged() {
        updateDateButtonTitle(with: datePicker.date)
    }

    private func updateDateButtonTitle(with date: Date) {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "ko_KR")
        let dateString = formatter.string(from: date)
        dateSelectButton.setTitle(dateString, for: .normal)
    }
}
