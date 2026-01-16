//
//  PreferenceCardEntity.swift
//  CulLecting
//
//  Created by 김승희 on 4/23/25.
//


struct PreferenceCardEntity: Codable {
    let keywords: [String]
    let culturalCount: Int
    let manyCategory: PreferenceCategory
}

enum PreferenceCategory: String, Codable {
    case 공연예술 = "공연예술"
    case 음악 = "음악"
    case 전시미술 = "전시/미술"
    case 축제야외체험 = "축제/야외체험"
    case 문화예술일반 = "문화/예술"
    case 교육체험 = "교육/체험"
    
    var imageName: String {
        switch self {
        case .공연예술: return "preferenceStage"
        case .음악: return "preferenceSound"
        case .전시미술: return "preferenceExhibition"
        case .축제야외체험: return "preferenceFestival"
        case .문화예술일반: return "preferenceCulture"
        case .교육체험: return "preferenceEducation"
        }
    }
}
