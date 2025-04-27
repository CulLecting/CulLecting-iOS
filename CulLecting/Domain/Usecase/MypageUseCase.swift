//
//  MypageUseCase.swift
//  CulLecting
//
//  Created by 김승희 on 4/27/25.
//


import Foundation

import RxSwift


protocol MypageUseCaseProtocol {
    
}

final class MypageUseCase: MypageUseCaseProtocol {

    private let repository: MypageRepositoryProtocol

    init(repository: MypageRepositoryProtocol) {
        self.repository = repository
    }
}
