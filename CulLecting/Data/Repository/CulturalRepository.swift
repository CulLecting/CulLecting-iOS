//
//  CulturalRepository.swift
//  CulLecting
//
//  Created by 김승희 on 4/29/25.
//


import RxSwift


final class CulturalRepository: CulturalRepositoryProtocol {
    
    func findCulturalImage(keyword: String) -> Single<[CulturalImageEntity]> {
        return NetworkManager.shared
            .request(CulturalAPI.findCulturalImage(keyword: keyword))
            .map { (dtos: [CulturalImageDTO]) in
                dtos.map { $0.mapping() }
            }
    }
    
    func recommendCultural() -> Single<[CulturalContentEntity]> {
        return NetworkManager.shared
            .request(CulturalAPI.recommendCultural)
            .map { (dtos: [RecommendCulturalDTO]) in
                dtos.map { $0.mapping() }
            }
    }
    
    func latestCultural() -> Single<[String: [CulturalContentEntity]]> {
        return NetworkManager.shared
            .request(CulturalAPI.latestCultural)
            .map { (dto: LatestCulturalResultDTO) in
                var result: [String: [CulturalContentEntity]] = [:]
                dto.result.forEach { (key, value) in
                    result[key] = value.map { $0.mapping() }
                }
                return result
            }
    }
    
    func findCulturalFromDate(date: String) -> Single<[CulturalContentEntity]> {
        return NetworkManager.shared
            .request(CulturalAPI.findCulturalFromDate(date: date))
            .map { (dtos: [CulturalNameDTO]) in
                dtos.map { $0.mapping() }
            }
    }
    
    func culturalDetail(id: Int) -> Single<CulturalDetailEntity> {
        return NetworkManager.shared
            .request(CulturalAPI.culturalDetail(id: id))
            .map { (dto: CulturalDetailDTO) in
                dto.mapping()
            }
    }
    
    func findCulturalName(keyword: String) -> Single<[CulturalContentEntity]> {
        return NetworkManager.shared
            .request(CulturalAPI.findCulturalName(keyword: keyword))
            .map { (dtos: [CulturalNameDTO]) in
                dtos.map { $0.mapping() }
            }
    }
    
    func culturalFilter(codeName: String?, guName: String?, themeCode: String?, isFree: Bool?) -> Single<[CulturalContentEntity]> {
        return NetworkManager.shared
            .request(CulturalAPI.culturalFilter(codeName: codeName, guName: guName, themeCode: themeCode, isFree: isFree))
            .map { (dtos: [CulturalNameDTO]) in
                dtos.map { $0.mapping() }
            }
    }
}
