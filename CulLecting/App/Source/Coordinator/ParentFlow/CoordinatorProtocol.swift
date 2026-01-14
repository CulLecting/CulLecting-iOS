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
