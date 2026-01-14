//
//  MypageCoordinator.swift
//  CulLecting
//
//  Created by 김승희 on 4/25/25.
//


import UIKit

import Swinject


protocol MypageCoordinatorProtocol: AnyObject {
    func didLogout()
}

final class MypageCoordinator: CoordinatorProtocol {
    var childCoordinators: [any CoordinatorProtocol] = []
    var navigationController: UINavigationController
    var finishDelegate: (any CoordinatorFinishDelegate)?
    var type = CoordinatorType.mypage

    private let injector: Resolver
    weak var parentCoordinator: TabbarCoordinator?

    init(injector: Resolver) {
        self.injector = injector
        self.navigationController = UINavigationController()
    }

    func start() {
        let viewModel = injector.resolve(MypageViewModel.self)!
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
