//
//  LoginAssembly.swift
//  CulLecting
//
//  Created by 김승희 on 4/7/25.
//

import UIKit
import Swinject

public struct LoginAssembly: Assembly {
    public func assemble(container: Container) {
        container.register(LoginCoordinator.self) { (resolver, navigationController: UINavigationController) in
            return LoginCoordinator(navigationController: navigationController)
        }
    }
}

