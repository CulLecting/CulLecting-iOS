//
//  Coordinator.swift
//  CulLecting
//
//  Created by 김승희 on 4/6/25.
//

import UIKit


public enum CoordinatorType {
    case app, login, onboarding, tabbar
}

public protocol Coordinator : AnyObject {
    var childCoordinators : [Coordinator] { get set }
    var navigationController: UINavigationController { get set }
    var type: CoordinatorType { get }
    var finishDelegate: CoordinatorFinishDelegate? { get set }
    
    func start()
    func finish()
}

extension Coordinator {
    public func finish() {
        childCoordinators.removeAll()
        finishDelegate?.coordinatorDidFinish(childCoordinator: self)
    }
}

public protocol CoordinatorFinishDelegate: AnyObject {
    func coordinatorDidFinish(childCoordinator: Coordinator)
}
