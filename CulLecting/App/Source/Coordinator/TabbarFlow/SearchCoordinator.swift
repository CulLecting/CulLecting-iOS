//
//  SearchCoordinator.swift
//  CulLecting
//
//  Created by 김승희 on 4/25/25.
//


import UIKit

import Swinject


protocol SearchCoordinatorProtocol {
    
}

final class SearchCoordinator: CoordinatorProtocol {
    var childCoordinators: [any CoordinatorProtocol] = []
    var navigationController: UINavigationController
    var finishDelegate: (any CoordinatorFinishDelegate)?
    var type = CoordinatorType.search
    
    private let injector: Resolver
    private let viewModel: SearchViewModel
    weak var parentCoordinator: TabbarCoordinator?
    
    init(injector: Resolver) {
        self.injector = injector
        self.viewModel = injector.resolve(SearchViewModel.self)!
        self.navigationController = UINavigationController()
    }
    
    func start() {
        let searchVC = SearchViewController(viewModel: viewModel, coordinator: self)
        navigationController.setViewControllers([searchVC], animated: false)
    }
    
}

extension SearchCoordinator: SearchCoordinatorProtocol {
    
}
