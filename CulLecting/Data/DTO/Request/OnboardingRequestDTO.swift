//
//  OnboardingRequestDTO.swift
//  CulLecting
//
//  Created by 김승희 on 4/16/25.
//


public struct OnboardingRequestDTO: Codable, Sendable {
    public let location: [String]
    public let category: [String]

    public init(location: [String], category: [String]) {
        self.location = location
        self.category = category
    }
}
