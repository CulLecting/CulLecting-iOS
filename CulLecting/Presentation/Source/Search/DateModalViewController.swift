//
//  DateModalViewController.swift
//  CulLecting
//
//  Created by SeungHwanMacBook on 5/8/25.
//

import UIKit
import SnapKit
import RxSwift

class DateModalViewController: UIViewController {
    
    private let viewModel: SearchViewModel
    private let coordinator: SearchCoordinator
    private let disposeBag = DisposeBag()

    //MARK: init
    init(viewModel: SearchViewModel, coordinator: SearchCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .inline // ✅ 캘린더 형식으로 고정
        picker.tintColor = .primary50
        picker.locale = Locale(identifier: "ko_KR")
        return picker
    }()
    
    private let resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("초기화", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 0.5
        button.backgroundColor = .grey5
        button.layer.cornerRadius = 25
        button.layer.masksToBounds = true
        return button
    }()

    private let applyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("적용하기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .grey90
        button.layer.cornerRadius = 25
        button.layer.masksToBounds = true
        return button
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [resetButton, applyButton])
        applyButton.addTarget(self, action: #selector(applyDate), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(resetDate), for: .touchUpInside)
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureSheetPresentation()
        datePicker.date = Date()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        
        view.addSubview(datePicker)
        view.addSubview(buttonStackView)
        
        datePicker.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(300) // ✅ DatePicker 높이 고정
        }
        
        buttonStackView.snp.makeConstraints {
            $0.top.equalTo(datePicker.snp.bottom).offset(16) // ✅ 위로 올림
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(50)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-12) // ✅ 아래 간격 고정
        }
    }
    
    private func configureSheetPresentation() {
        guard let sheet = sheetPresentationController else { return }
        
        if #available(iOS 16.0, *) {
            let fixedHeight = UISheetPresentationController.Detent.custom { _ in return 400 }
            sheet.detents = [fixedHeight]
        } else {
            sheet.detents = [.medium()]
        }
        
        sheet.prefersGrabberVisible = true
        sheet.preferredCornerRadius = 16
    }
    
    @objc private func resetDate() {
        print("날짜 초기화")
        let today = Date()
        datePicker.setDate(today, animated: true)
    }
    
    @objc private func applyDate() {
        print("날짜 적용")
        let selectedDate = datePicker.date
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul") // ✅ 한국 시간대 (KST)
        
        let formattedDate = formatter.string(from: selectedDate)
        print("선택된 날짜 (KST): \(formattedDate)")
        viewModel.findDataFromDate(date: formattedDate)
        dismiss(animated: true)
    }
}

