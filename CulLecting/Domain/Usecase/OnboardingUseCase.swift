//
//  OnboardingUseCase.swift
//  CulLecting
//
//  Created by 김승희 on 4/22/25.
//


import Foundation

import RxSwift


protocol OnboardingUseCaseProtocol {
    func updateOnboarding(location: [String], category: [String]) -> Completable
}

final class OnboardingUseCase: OnboardingUseCaseProtocol {

    private let repository: OnboardingRepositoryProtocol

    init(repository: OnboardingRepositoryProtocol) {
        self.repository = repository
    }

    func updateOnboarding(location: [String], category: [String]) -> Completable {
        return repository.updateOnboarding(location: location, category: category)
    }
}
