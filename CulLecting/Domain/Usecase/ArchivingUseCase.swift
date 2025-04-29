//
//  ArchivingUseCaseProtocol.swift
//  CulLecting
//
//  Created by 김승희 on 4/23/25.
//


import UIKit

import RxSwift


protocol ArchivingUseCaseProtocol {
    func uploadArchiving(image: UIImage, title: String, description: String, date: String, category: String, template: String) -> Completable
    func uploadArchiveImg(image: UIImage) -> Single<String>
    func fetchArchiving() -> Single<[Ticket]>
    func fetchTicket(id: String) -> Single<Ticket>
    func deleteArchiving(id: String) -> Completable
    func updateArchiving(id: String, title: String, description: String, date: String, category: String) -> Completable
    func updateImage(id: String, image: UIImage) -> Completable
    func updateTemplate(id: String, template: String) -> Completable
    func getPreferenceCard() -> Single<PreferenceCardEntity?>
}

final class ArchivingUseCase: ArchivingUseCaseProtocol {
    
    private let repository: ArchivingRepository
    
    init(repository: ArchivingRepository = ArchivingRepository()) {
        self.repository = repository
    }
    
    func uploadArchiving(image: UIImage, title: String, description: String, date: String, category: String, template: String) -> Completable {
        return repository.uploadArchiving(image: image, title: title, description: description, date: date, category: category, template: template)
    }
    
    //TODO: api 주면 수정
    func uploadArchiveImg(image: UIImage) -> Single<String> {
        return Single.just("0")
    }
    
    func fetchArchiving() -> Single<[Ticket]> {
        return repository.fetchArchiving()
    }
    
    //TODO: api 주면 수정
    func fetchTicket(id: String) -> Single<Ticket> {
        let dummyTicket = Ticket(
            id: id,
            title: "더미 티켓",
            description: "이건 목 데이터입니다.",
            date: "2025-05-01",
            imageURL: "https://example.com/dummy.jpg",
            category: "전시/미술",
            template: "basic",
            averageColorHex: "#FFFFFF"
        )
        return Single.just(dummyTicket)
    }
    
    func deleteArchiving(id: String) -> Completable {
        return repository.deleteArchiving(id: id)
    }
    
    func updateArchiving(id: String, title: String, description: String, date: String, category: String) -> Completable {
        return repository.updateArchiving(id: id, title: title, description: description, date: date, category: category)
    }
    
    func updateImage(id: String, image: UIImage) -> Completable {
        return repository.updateImage(id: id, image: image)
    }
    
    func updateTemplate(id: String, template: String) -> Completable {
        return repository.updateTemplate(id: id, template: template)
    }
    
    func getPreferenceCard() -> Single<PreferenceCardEntity?> {
        return NetworkManager.shared.request(ArchivingAPI.getPreferenceCard)
            .map { Optional($0) }
    }
}
