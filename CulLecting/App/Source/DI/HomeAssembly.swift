//
//  HomeAssembly.swift
//  CulLecting
//
//  Created by 김승희 on 4/7/25.
//


import UIKit

import Swinject

public struct HomeAssembly: Assembly {
    public func assemble(container: Container) {
        container.register(CulturalRepositoryProtocol.self) { _ in
            CulturalRepository()
        }
        
        container.register(ArchiveRepositoryProtocol.self) { _ in
            ArchivingRepository()
        }

        container.register(HomeUseCaseProtocol.self) { r in
            guard let culturalRepo = r.resolve(CulturalRepositoryProtocol.self),
                  let archiveRepo = r.resolve(ArchiveRepositoryProtocol.self) else {
                fatalError("Repositories not resolved")
            }
            return HomeUseCase(archiveRepository: archiveRepo, culturalRepository: culturalRepo)
        }

        container.register(HomeViewModel.self) { r in
            let useCase = r.resolve(HomeUseCaseProtocol.self)!
            return HomeViewModel(useCase: useCase)
        }

        container.register(HomeCoordinator.self) { (r, navigationController: UINavigationController) in
            return HomeCoordinator(injector: r)
        }
    }
}
