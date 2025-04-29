//
//  SearchViewController.swift
//  CulLecting
//
//  Created by 김승희 on 4/7/25.
//


import UIKit


class SearchViewController: UIViewController {
    //MARK: Properties
    private let viewModel: SearchViewModel
    private let coordinator: SearchCoordinator
    
    //MARK: UI Components
    
    //MARK: init
    init(viewModel: SearchViewModel, coordinator: SearchCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBlue
    }

}

