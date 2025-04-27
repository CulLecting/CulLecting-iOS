//
//  PreferenceCardDTO.swift
//  CulLecting
//
//  Created by 김승희 on 4/23/25.
//


struct PreferenceCardResponse: Decodable {
    let status: Int
    let message: String
    let data: PreferenceCardData
}

struct PreferenceCardData: Codable {
    let keywords: [String]
    let culturalCount: Int
    let manyCategory: String
}
