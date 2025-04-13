//
//  TabbarAssembly.swift
//  CulLecting
//
//  Created by 김승희 on 4/7/25.
//


import UIKit
import Swinject

public struct TabBarCoordinatorAssembly: Assembly {
    public func assemble(container: Container) {
        container.register(TabbarCoordinator.self) { (resolver, navigationController: UINavigationController) -> TabbarCoordinator in
            let dependency = TabbarCoordinator.Dependency(
                navigationController: navigationController,
                injector: resolver,
                finishDelegate: nil
            )
            return TabbarCoordinator(dependency: dependency)
        }
    }
}
