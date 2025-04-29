//
//  PreferenceCardDTO.swift
//  CulLecting
//
//  Created by 김승희 on 4/23/25.
//


import Foundation

struct PreferenceCardDTO: Decodable {
    let keywords: [String]
    let culturalCount: Int
    let manyCategory: String
    
    func mapping() -> PreferenceCardEntity {
        return PreferenceCardEntity(
            keywords: keywords,
            culturalCount: culturalCount,
            manyCategory: manyCategory
        )
    }
}
