//
//  HomeUseCase.swift
//  CulLecting
//
//  Created by 김승희 on 4/27/25.
//


import Foundation

import RxSwift


protocol HomeUseCaseProtocol {
    func fetchMyArchivingTickets() -> Single<[Ticket]>
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
    
    func fetchMyArchivingTickets() -> Single<[Ticket]> {
        return archiveRepository.fetchArchiving()
            .catch { error in
                if case NetworkError.serverMessage(let message) = error,
                   message.contains("등록된 아카이빙 데이터가 없습니다") {
                    return .just([])
                }
                return .error(error)
            }
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
