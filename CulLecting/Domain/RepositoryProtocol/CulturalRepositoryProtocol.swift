//
//  CulturalRepositoryProtocol.swift
//  CulLecting
//
//  Created by 김승희 on 4/29/25.
//


import RxSwift


protocol CulturalRepositoryProtocol {
    func findCulturalImage(keyword: String) -> Single<[CulturalImageEntity]>
    func recommendCultural() -> Single<[CulturalContentEntity]>
    func latestCultural() -> Single<[String: [CulturalContentEntity]]>
    func findCulturalFromDate(date: String) -> Single<[CulturalContentEntity]>
    func culturalDetail(id: Int) -> Single<CulturalDetailEntity>
    func findCulturalName(keyword: String) -> Single<[CulturalContentEntity]>
    func culturalFilter(codeName: String?, guName: String?, themeCode: String?, isFree: Bool?) -> Single<[CulturalContentEntity]>
}
