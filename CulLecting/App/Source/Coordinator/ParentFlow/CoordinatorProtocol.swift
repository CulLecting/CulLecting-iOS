//
//  Coordinator.swift
//  CulLecting
//
//  Created by 김승희 on 4/6/25.
//

import UIKit

public protocol CoordinatorProtocol: AnyObject {
    var childCoordinators: [CoordinatorProtocol] { get set }
    var navigationController: UINavigationController { get set }
    var parentCoordinator: CoordinatorProtocol? { get set }
    
    func start()
    func finish()
}

public extension CoordinatorProtocol {

    func addChild(_ coordinator: CoordinatorProtocol) {
        childCoordinators.append(coordinator)
        coordinator.parentCoordinator = self
    }

    func removeChild(_ coordinator: CoordinatorProtocol) {
        childCoordinators.removeAll { $0 === coordinator }
    }

    func finish() {
        childCoordinators.forEach { $0.finish() }
        childCoordinators.removeAll()
        parentCoordinator?.removeChild(self)
    }
}
