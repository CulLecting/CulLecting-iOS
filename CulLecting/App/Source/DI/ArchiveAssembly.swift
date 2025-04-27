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
            return ArchiveViewModel(useCase: useCase)
        }
        
        container.register(AddTicketViewModel.self) { r in
            let useCase = r.resolve(ArchivingUseCase.self)!
            return AddTicketViewModel(useCase: useCase)
        }
    }
}
