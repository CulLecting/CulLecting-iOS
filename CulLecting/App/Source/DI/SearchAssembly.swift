//
//  SearchAssembly.swift
//  CulLecting
//
//  Created by 김승희 on 4/7/25.
//

import Swinject

struct SearchAssembly: Assembly {

    func assemble(container: Container) {
        // Repository
        container.register(CulturalRepositoryProtocol.self) { _ in
            CulturalRepository()
        }

        // UseCase
        container.register(SearchUseCase.self) { r in
            let repository = r.resolve(CulturalRepositoryProtocol.self)!
            return SearchUseCase(repository: repository)
        }

        // ViewModel
        container.register(SearchViewModel.self) { r in
            let useCase = r.resolve(SearchUseCase.self)!
            return SearchViewModel(useCase: useCase)
        }

        // ViewController
        container.register(SearchViewController.self) { (r, coordinator: SearchCoordinator) in
            let viewModel = r.resolve(SearchViewModel.self)!
            return SearchViewController(viewModel: viewModel, coordinator: coordinator)
        }
    }
}
