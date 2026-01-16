//
//  HomeAssembly.swift
//  CulLecting
//
//  Created by 김승희 on 4/7/25.
//

import Swinject

struct HomeAssembly: Assembly {

    func assemble(container: Container) {
        // Repository
        container.register(CulturalRepositoryProtocol.self) { _ in
            CulturalRepository()
        }

        container.register(ArchiveRepositoryProtocol.self) { _ in
            ArchivingRepository()
        }

        // UseCase
        container.register(HomeUseCaseProtocol.self) { r in
            guard let culturalRepo = r.resolve(CulturalRepositoryProtocol.self),
                  let archiveRepo = r.resolve(ArchiveRepositoryProtocol.self) else {
                fatalError("Repositories not resolved")
            }
            return HomeUseCase(archiveRepository: archiveRepo, culturalRepository: culturalRepo)
        }

        // ViewModel
        container.register(HomeViewModel.self) { r in
            let useCase = r.resolve(HomeUseCaseProtocol.self)!
            return HomeViewModel(useCase: useCase)
        }

        // ViewController
        container.register(HomeViewController.self) { (r, coordinator: HomeCoordinator) in
            let viewModel = r.resolve(HomeViewModel.self)!
            return HomeViewController(viewModel: viewModel, coordinator: coordinator)
        }
    }
}
