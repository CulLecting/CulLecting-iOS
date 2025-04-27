//
//  ArchivingRepository.swift
//  CulLecting
//
//  Created by 김승희 on 4/23/25.
//


import UIKit

import RxSwift


final class ArchivingRepository: ArchivingRepositoryProtocol {
    
    func uploadArchiving(image: UIImage, title: String, description: String, date: String, category: String, template: String) -> Completable {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            return .error(NetworkError.invalidImageData)
        }
        
        return NetworkManager.shared
            .requestWithoutData(
                ArchivingAPI.uploadArchiving(
                    image: imageData,
                    title: title,
                    description: description,
                    date: date,
                    category: category,
                    template: template
                )
            )
    }

    func fetchArchiving() -> Single<[Ticket]> {
        return NetworkManager.shared.request(
            ArchivingAPI.fetchArchiving
        )
    }

    func deleteArchiving(id: String) -> Completable {
        return NetworkManager.shared
            .requestWithoutData(
                ArchivingAPI.deleteArchiving(id: id)
            )
    }

    func updateArchiving(id: String, title: String, description: String, date: String, category: String) -> Completable {
        return NetworkManager.shared
            .requestWithoutData(
                ArchivingAPI.updateArchiving(
                    id: id,
                    title: title,
                    description: description,
                    date: date,
                    category: category
                )
            )
    }

    func updateImage(id: String, image: UIImage) -> Completable {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            return .error(NetworkError.invalidImageData)
        }
        return NetworkManager.shared
            .requestWithoutData(
                ArchivingAPI.updateImage(id: id, image: imageData)
            )
    }

    func updateTemplate(id: String, template: String) -> Completable {
        return NetworkManager.shared
            .requestWithoutData(
                ArchivingAPI.updateTemplate(id: id, template: template)
            )
    }

    func getPreferenceCard() -> Single<PreferenceCardEntity> {
        return NetworkManager.shared.request(
            ArchivingAPI.getPreferenceCard
        )
    }
}
