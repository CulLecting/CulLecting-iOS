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
    func getPreferenceCard() -> Single<PreferenceCardEntity>
}

final class ArchivingUseCase: ArchivingUseCaseProtocol {
    private let repository: ArchiveRepositoryProtocol

    init(repository: ArchiveRepositoryProtocol = ArchivingRepository()) {
        self.repository = repository
    }

    func uploadArchiving(image: UIImage, title: String, description: String, date: String, category: String, template: String) -> Completable {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            return .error(NetworkError.invalidImageData)
        }

        let dto = UploadArchivingRequestDTO(
            image: imageData,
            title: title,
            description: description,
            date: date,
            category: category,
            template: template
        )
        return repository.uploadArchiving(dto: dto)
    }

    func uploadArchiveImg(image: UIImage) -> Single<String> {
        return repository.uploadArchiveImg(image: image)
    }

    func fetchArchiving() -> Single<[Ticket]> {
        return repository.fetchArchiving()
            .catch { error in
                if case NetworkError.serverMessage(let message) = error,
                   message.contains("등록된 아카이빙 데이터가 없습니다") {
                    return .just([])
                }
                return .error(error)
            }
    }

    func fetchTicket(id: String) -> Single<Ticket> {
        return repository.fetchTicket(id: id)
    }

    func deleteArchiving(id: String) -> Completable {
        return repository.deleteArchiving(id: id)
    }

    func updateArchiving(id: String, title: String, description: String, date: String, category: String) -> Completable {
        let dto = UpdateArchivingRequestDTO(
            id: id,
            title: title,
            description: description,
            date: date,
            category: category
        )
        return repository.updateArchiving(dto: dto)
    }

    func updateImage(id: String, image: UIImage) -> Completable {
        return repository.updateImage(id: id, image: image)
    }

    func updateTemplate(id: String, template: String) -> Completable {
        let dto = UpdateTemplateRequestDTO(id: id, template: template)
        return repository.updateTemplate(dto: dto)
    }

    func getPreferenceCard() -> Single<PreferenceCardEntity> {
        return repository.getPreferenceCard()
    }
}

