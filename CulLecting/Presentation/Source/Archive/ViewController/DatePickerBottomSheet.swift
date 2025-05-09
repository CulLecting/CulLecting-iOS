//
//  DatePickerBottomSheet.swift
//  CulLecting
//
//  Created by 김승희 on 5/7/25.
//


import UIKit


import UIKit

final class DatePickerBottomSheet: UIViewController {
    
    var onDateSelected: ((Date) -> Void)?
    
    private let picker = UIDatePicker().then {
        $0.datePickerMode = .date
        $0.preferredDatePickerStyle = .wheels
        $0.locale = Locale(identifier: "ko_KR")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNav()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(picker)
        picker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            picker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            picker.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupNav() {
        title = "날짜 선택"
        let navItem = UINavigationItem(title: "")
        let doneButton = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(doneTapped))
        navigationItem.rightBarButtonItem = doneButton
    }
    
    @objc private func doneTapped() {
        onDateSelected?(picker.date)
        dismiss(animated: true)
    }
}
