//
//  OnboardingRepositoryProtocol.swift
//  CulLecting
//
//  Created by 김승희 on 4/22/25.
//


import Foundation

import RxSwift

protocol OnboardingRepositoryProtocol {
    func updateOnboarding(location: [String], category: [String]) -> Completable
}
