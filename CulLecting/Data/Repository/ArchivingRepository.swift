//
//  ArchivingRepository.swift
//  CulLecting
//
//  Created by 김승희 on 4/23/25.
//


import UIKit

import RxSwift


import UIKit
import RxSwift

final class ArchivingRepository: ArchivingRepositoryProtocol {
    
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
        return NetworkManager.shared
            .requestWithoutData(ArchivingAPI.uploadArchiving(dto: dto))
    }

    func uploadArchiveImg(image: UIImage) -> Single<String> {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            return .error(NetworkError.invalidImageData)
        }
        return NetworkManager.shared
            .request(ArchivingAPI.uploadArchiveImg(image: imageData))
            .map { (response: UploadArchiveImgResponseDTO) in
                return response.data.id
            }
    }

    func fetchArchiving() -> Single<[Ticket]> {
        return (NetworkManager.shared
                .request(ArchivingAPI.fetchArchiving) as Single<[ArchivingDTO]>)
            .map { $0.map { $0.mapping() } }
            .catch { error in
                if case NetworkError.noData = error {
                    return Single.just([])
                }
                return Single.error(error)
            }
    }

    func fetchSingleTicket(id: String) -> Single<Ticket> {
        return (NetworkManager.shared
            .request(ArchivingAPI.fetchSingleTicket(id: id)) as Single<ArchivingDTO>)
            .map { $0.mapping() }
    }

    func updateArchiving(id: String, title: String, description: String, date: String, category: String) -> Completable {
        let dto = UpdateArchivingRequestDTO(
            id: id,
            title: title,
            description: description,
            date: date,
            category: category
        )
        return NetworkManager.shared
            .requestWithoutData(ArchivingAPI.updateArchiving(dto: dto))
    }

    func updateImage(id: String, image: UIImage) -> Completable {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            return .error(NetworkError.invalidImageData)
        }
        let dto = UpdateImageRequestDTO(id: id, image: imageData)
        return NetworkManager.shared
            .requestWithoutData(ArchivingAPI.updateImage(dto: dto))
    }

    func updateTemplate(id: String, template: String) -> Completable {
        let dto = UpdateTemplateRequestDTO(id: id, template: template)
        return NetworkManager.shared
            .requestWithoutData(ArchivingAPI.updateTemplate(dto: dto))
    }

    func deleteArchiving(id: String) -> Completable {
        return NetworkManager.shared
            .requestWithoutData(ArchivingAPI.deleteArchiving(id: id))
    }

    func getPreferenceCard() -> Single<PreferenceCardEntity> {
        return (NetworkManager.shared
            .request(ArchivingAPI.getPreferenceCard) as Single<PreferenceCardDTO>)
        .map { $0.mapping() }
        .catch { error in
            if case NetworkError.noData = error {
                return Single.just(PreferenceCardEntity(keywords: [], culturalCount: 0, manyCategory: ""))
            }
            return Single.error(error)
        }
    }
}
