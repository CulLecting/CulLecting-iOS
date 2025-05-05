//
//  SearchUseCase.swift
//  CulLecting
//
//  Created by 김승희 on 4/27/25.
//


import Foundation

import RxSwift


protocol SearchUseCaseProtocol {
    
}

final class SearchUseCase: SearchUseCaseProtocol {

    private let repository: CulturalRepositoryProtocol

    init(repository: CulturalRepositoryProtocol) {
        self.repository = repository
    }
}
