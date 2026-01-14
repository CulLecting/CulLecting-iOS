//
//  ArchiveAssembly.swift
//  CulLecting
//
//  Created by 김승희 on 4/7/25.
//


import UIKit

import Swinject

public struct ArchiveAssembly: Assembly {
    public func assemble(container: Container) {
        
        container.register(ArchivingRepository.self) { _ in
            ArchivingRepository()
        }
        
        container.register(ArchivingUseCase.self) { r in
            let repository = r.resolve(ArchivingRepository.self)!
            return ArchivingUseCase(repository: repository)
        }
        
        container.register(ArchiveViewModel.self) { r in
            let useCase = r.resolve(ArchivingUseCase.self)!
            let authUseCase = r.resolve(AuthUseCaseProtocol.self)!
            return ArchiveViewModel(useCase: useCase, authUseCase: authUseCase)
        }
        
        container.register(SearchCulturalInfoViewModel.self) { r, actionType in
            guard let culturalRepo = r.resolve(CulturalRepositoryProtocol.self),
                  let archivingUseCase = r.resolve(ArchivingUseCase.self) else {
                fatalError("Dependencies not resolved")
            }
            return SearchCulturalInfoViewModel(
                culturalRepository: culturalRepo,
                archivingUseCase: archivingUseCase,
                actionType: actionType
            )
        }

        container.register(TicketEditViewModel.self) { r, ticket in
            let useCase = r.resolve(ArchivingUseCase.self)!
            return TicketEditViewModel(useCase: useCase, ticket: ticket)
        }
        
        container.register(TicketDetailViewModel.self) { r in
            let useCase = r.resolve(ArchivingUseCase.self)!
            return TicketDetailViewModel(useCase: useCase)
        }
    }
}
