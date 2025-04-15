//
//  EditInfoViewController.swift
//  CulLecting
//
//  Created by 김승희 on 4/13/25.
//


import UIKit


class EditInfoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .grey10
        setNavigationBar()
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: false)

        let backAction = UIAction { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }

        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            primaryAction: backAction,
            menu: nil
        )
        backButton.tintColor = UIColor.grey90
        navigationItem.leftBarButtonItem = backButton
        navigationItem.title = "내 정보 수정"
    }
}
