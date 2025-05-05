//
//  CulturalDTO.swift
//  CulLecting
//
//  Created by 김승희 on 4/29/25.
//


import Foundation


struct CulturalImageDTO: Decodable {
    let title: String
    let imageURL: String
}

struct RecommendCulturalDTO: Decodable {
    let id: Int
    let imageURL: String
    let title: String
    let place: String
}

struct LatestCulturalItemDTO: Decodable {
    let id: Int
    let title: String
    let imageURL: String
    let place: String
    let startDate: String
    let endDate: String
}

struct LatestCulturalResultDTO: Decodable {
    let result: [String: [LatestCulturalItemDTO]]
}

struct CulturalDetailDTO: Decodable {
    let id: Int
    let title: String
    let codename: String
    let guname: String
    let place: String
    let orgName: String
    let orgLink: String
    let mainImg: String
    let themeCode: String
    let startDate: String
    let endDate: String
    let date: String
    let lot: String
    let lat: String
    let hmpgAddr: String
    let lastUpdated: String
    let free: Bool
}

struct CulturalNameDTO: Decodable {
    let id: Int
    let title: String
    let imageURL: String
    let place: String
    let startDate: String
    let endDate: String
}

// MARK: - DTO -> Entity 변환
extension CulturalImageDTO {
    func mapping() -> CulturalImageEntity {
        return CulturalImageEntity(title: title, imageURL: imageURL)
    }
}

extension RecommendCulturalDTO {
    func mapping() -> CulturalContentEntity {
        return CulturalContentEntity(
            id: id,
            title: title,
            imageURL: imageURL,
            place: place,
            startDate: nil,
            endDate: nil
        )
    }
}

extension LatestCulturalItemDTO {
    func mapping() -> CulturalContentEntity {
        return CulturalContentEntity(
            id: id,
            title: title,
            imageURL: imageURL,
            place: place,
            startDate: startDate,
            endDate: endDate
        )
    }
}

extension CulturalNameDTO {
    func mapping() -> CulturalContentEntity {
        return CulturalContentEntity(
            id: id,
            title: title,
            imageURL: imageURL,
            place: place,
            startDate: startDate,
            endDate: endDate
        )
    }
}

extension CulturalDetailDTO {
    func mapping() -> CulturalDetailEntity {
        return CulturalDetailEntity(
            id: id,
            title: title,
            codename: codename,
            guname: guname,
            place: place,
            orgName: orgName,
            orgLink: orgLink,
            mainImg: mainImg,
            themeCode: themeCode,
            startDate: startDate,
            endDate: endDate,
            date: date,
            lot: lot,
            lat: lat,
            hmpgAddr: hmpgAddr,
            lastUpdated: lastUpdated,
            free: free
        )
    }
}
