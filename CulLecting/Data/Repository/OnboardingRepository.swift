//
//  OnboardingRepository.swift
//  CulLecting
//
//  Created by 김승희 on 4/22/25.
//


import Foundation

import RxSwift

final class OnboardingRepository: OnboardingRepositoryProtocol {
    
    func updateOnboarding(location: [String], category: [String]) -> Completable {
        let dto = OnboardingRequestDTO(location: location, category: category)
        return NetworkManager.shared
            .requestWithoutData(OnboardingAPI.updateOnboarding(dto))
    }
}
