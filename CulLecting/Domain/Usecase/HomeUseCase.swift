//
//  HomeUseCase.swift
//  CulLecting
//
//  Created by 김승희 on 4/27/25.
//


import Foundation

import RxSwift


protocol HomeUseCaseProtocol {
    
}

final class HomeUseCase: HomeUseCaseProtocol {

    private let repository: HomeRepositoryProtocol

    init(repository: HomeRepositoryProtocol) {
        self.repository = repository
    }
}
