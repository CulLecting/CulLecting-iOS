//
//  HomeUseCase.swift
//  CulLecting
//
//  Created by 김승희 on 4/27/25.
//


import Foundation

import RxSwift


protocol HomeUseCaseProtocol {
    func fetchArchiving() -> Single<[Ticket]>
    func searchCulturalImages(keyword: String) -> Single<[CulturalImageEntity]>
    func fetchRecommendCultural() -> Single<[CulturalContentEntity]>
    func fetchLatestCultural() -> Single<[String: [CulturalContentEntity]]>
    func findCultural(from date: Date) -> Single<[CulturalContentEntity]>
}

final class HomeUseCase: HomeUseCaseProtocol {
    private let archiveRepository: ArchiveRepositoryProtocol
    private let culturalRepository: CulturalRepositoryProtocol
    
    init(
        archiveRepository: ArchiveRepositoryProtocol,
        culturalRepository: CulturalRepositoryProtocol
    ) {
        self.archiveRepository = archiveRepository
        self.culturalRepository = culturalRepository
    }
    
    func fetchArchiving() -> Single<[Ticket]> {
        return NetworkManager.shared
            .request([ArchivingDTO].self, ArchivingAPI.fetchArchiving)
            .map { $0.map { $0.mapping() } }
    }
    
    func searchCulturalImages(keyword: String) -> Single<[CulturalImageEntity]> {
        return culturalRepository.findCulturalImage(keyword: keyword)
    }
    
    func fetchRecommendCultural() -> Single<[CulturalContentEntity]> {
        return culturalRepository.recommendCultural()
    }
    
    func fetchLatestCultural() -> Single<[String: [CulturalContentEntity]]> {
        return culturalRepository.latestCultural()
    }
    func findCultural(from date: Date) -> Single<[CulturalContentEntity]> {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)
        return culturalRepository.findCulturalFromDate(date: dateString)
    }
}
