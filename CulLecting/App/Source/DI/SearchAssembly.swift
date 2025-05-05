//
//  SearchAssembly.swift
//  CulLecting
//
//  Created by 김승희 on 4/7/25.
//


import UIKit
import Swinject


public struct SearchAssembly: Assembly {
    public func assemble(container: Container) {
        container.register(CulturalRepositoryProtocol.self) { _ in
            CulturalRepository()
        }

        container.register(SearchUseCase.self) { r in
            let repository = r.resolve(CulturalRepositoryProtocol.self)!
            return SearchUseCase(repository: repository)
        }

        container.register(SearchViewModel.self) { r in
            let useCase = r.resolve(SearchUseCase.self)!
            return SearchViewModel(useCase: useCase)
        }

        container.register(SearchCoordinator.self) { (r, navigationController: UINavigationController) in
            return SearchCoordinator(injector: r)
        }
    }
}
