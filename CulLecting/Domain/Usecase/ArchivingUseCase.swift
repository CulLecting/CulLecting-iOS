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
    func fetchArchiving() -> Single<[Ticket]>
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
    
    func fetchArchiving() -> Single<[Ticket]> {
        return repository.fetchArchiving()
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
