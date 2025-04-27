//
//  Coordinator.swift
//  CulLecting
//
//  Created by 김승희 on 4/6/25.
//


import UIKit


public protocol CoordinatorProtocol : AnyObject {
    var childCoordinators : [CoordinatorProtocol] { get set }
    var navigationController: UINavigationController { get set }
    var type: CoordinatorType { get }
    var finishDelegate: CoordinatorFinishDelegate? { get set }
    
    func start()
    func finish()
}

extension CoordinatorProtocol {
    public func finish() {
        childCoordinators.removeAll()
        finishDelegate?.coordinatorDidFinish(childCoordinator: self)
    }
}

public protocol CoordinatorFinishDelegate: AnyObject {
    func coordinatorDidFinish(childCoordinator: CoordinatorProtocol)
}
