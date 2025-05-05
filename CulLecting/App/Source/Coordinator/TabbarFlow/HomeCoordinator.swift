//
//  HomeCoordinator.swift
//  CulLecting
//
//  Created by 김승희 on 4/25/25.
//


import UIKit

import Swinject


protocol HomeCoordinatorProtocol: AnyObject {

}

final class HomeCoordinator: CoordinatorProtocol {
    var childCoordinators: [any CoordinatorProtocol] = []
    var navigationController: UINavigationController
    var finishDelegate: (any CoordinatorFinishDelegate)?
    var type: CoordinatorType = .home
    
    private let injector: Resolver
    private let viewModel: HomeViewModel
    weak var parentCoordinator: TabbarCoordinator?
    
    init(injector: Resolver) {
        self.injector = injector
        self.viewModel = injector.resolve(HomeViewModel.self)!
        self.navigationController = UINavigationController()
    }

    func start() {
        let homeVC = HomeViewController(viewModel: viewModel, coordinator: self)
        navigationController.setViewControllers([homeVC], animated: false)
    }
    
    func moveToArchiveTab() {
        parentCoordinator?.switchTab(to: .archive)
    }

}

extension HomeCoordinator: HomeCoordinatorProtocol {

}
