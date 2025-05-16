//
//  MypageCoordinator.swift
//  CulLecting
//
//  Created by 김승희 on 4/25/25.
//


import UIKit

import Swinject


protocol MypageCoordinatorProtocol {
    
}

final class MypageCoordinator: CoordinatorProtocol {
    var childCoordinators: [any CoordinatorProtocol] = []
    var navigationController: UINavigationController
    var finishDelegate: (any CoordinatorFinishDelegate)?
    var type = CoordinatorType.mypage
    
    private let injector: Resolver
    private let viewModel: MypageViewModel
    weak var parentCoordinator: TabbarCoordinator?
    
    init(injector: Resolver) {
        self.injector = injector
        self.viewModel = injector.resolve(MypageViewModel.self)!
        self.navigationController = UINavigationController()
    }
    
    func start() {
        let mypageVC = MypageViewController(viewModel: viewModel, coordinator: self)
        navigationController.setViewControllers([mypageVC], animated: false)
    }
    
    func didLogout() {
        print("didLogout called")
        parentCoordinator?.logoutAndStartLoginFlow()
    }

}

extension MypageCoordinator: MypageCoordinatorProtocol {
    
}
