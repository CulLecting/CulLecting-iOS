//
//  AppAssembly.swift
//  CulLecting
//
//  Created by 김승희 on 4/7/25.
//

import UIKit
import Swinject

public struct AppAssembly: Assembly {
    public func assemble(container: Container) {
        // 각 모듈별 Assembly를 호출하여 컨테이너에 등록
        DataAssembly().assemble(container: container)
        DomainAssembly().assemble(container: container)
        AuthAssembly().assemble(container: container)
        OnboardingAssembly().assemble(container: container)
        HomeAssembly().assemble(container: container)
        ArchiveAssembly().assemble(container: container)
        SearchAssembly().assemble(container: container)
        MyPageAssembly().assemble(container: container)
        TabBarCoordinatorAssembly().assemble(container: container)
        
        // AppCoordinatorProtocol 등록
        container.register(DefaultAppCoordinatorProtocol.self) { (resolver, navigationController: UINavigationController, window: UIWindow) in
            let dependency = DefaultAppCoordinator.Dependency(
                navigationController: navigationController,
                injector: resolver
            )
            return DefaultAppCoordinator(dependency: dependency)
        }
    }
    
}
