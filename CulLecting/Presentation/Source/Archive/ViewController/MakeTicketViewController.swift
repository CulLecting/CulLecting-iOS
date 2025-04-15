//
//  MakeTicketViewController.swift
//  CulLecting
//
//  Created by 김승희 on 4/13/25.
//


import UIKit

import FlexLayout
import PinLayout
import Then


class MakeTicketViewController: UIViewController {
    
    private let container = UIView()
    
    
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        setUI()
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        container.pin.all(view.pin.safeArea)
        container.flex.layout()
    }
    
    //MARK: 기타 메서드
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
        navigationItem.title = "기록 추가하기"
    }
    
    //MARK: UI
    private func setUI() {
        view.backgroundColor = .white
        view.addSubview(container)
    }
}
