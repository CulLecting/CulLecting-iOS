//
//  MyPageViewController.swift
//  CulLecting
//
//  Created by 김승희 on 4/7/25.
//


import UIKit


class MyPageViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBlue
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
