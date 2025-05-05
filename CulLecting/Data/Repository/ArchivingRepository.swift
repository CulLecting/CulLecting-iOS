//
//  ArchivingRepository.swift
//  CulLecting
//
//  Created by 김승희 on 4/23/25.
//


import UIKit

import Alamofire
import RxSwift


final class ArchivingRepository: ArchiveRepositoryProtocol {

    func uploadArchiving(dto: UploadArchivingRequestDTO) -> Completable {
        return NetworkManager.shared.uploadMultipart(
            to: ArchivingAPI.uploadArchiving,
            image: dto.image,
            parameters: [
                "title": dto.title,
                "description": dto.description,
                "date": dto.date,
                "category": dto.category,
                "template": dto.template
            ]
        )
    }

    func uploadArchiveImg(image: UIImage) -> Single<String> {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            return .error(NetworkError.invalidImageData)
        }

        return NetworkManager.shared.uploadMultipartWithResponse(
            to: ArchivingAPI.uploadArchiveImg,
            image: imageData,
            parameters: nil,
            responseType: UploadArchiveImgResponseDTO.self
        )
        .map { $0.data.id }
    }

    func fetchArchiving() -> Single<[Ticket]> {
        return NetworkManager.shared
            .request(ArchivingAPI.fetchArchiving) as Single<[Ticket]>
    }

    func fetchTicket(id: String) -> Single<Ticket> {
        return NetworkManager.shared
            .request(ArchivingAPI.fetchSingleTicket(id: id)) as Single<Ticket>
    }

    func updateArchiving(dto: UpdateArchivingRequestDTO) -> Completable {
        return NetworkManager.shared.requestWithoutData(
            ArchivingAPI.updateArchiving(id: dto.id, dto: dto)
        )
    }

    func updateImage(id: String, image: UIImage) -> Completable {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            return .error(NetworkError.invalidImageData)
        }

        return NetworkManager.shared.uploadMultipart(
            to: ArchivingAPI.updateImage(id: id),
            image: imageData,
            parameters: nil
        )
    }

    func updateTemplate(dto: UpdateTemplateRequestDTO) -> Completable {
        return NetworkManager.shared.requestWithoutData(
            ArchivingAPI.updateTemplate(id: dto.id, template: dto.template)
        )
    }

    func deleteArchiving(id: String) -> Completable {
        return NetworkManager.shared.requestWithoutData(
            ArchivingAPI.deleteArchiving(id: id)
        )
    }

    func getPreferenceCard() -> Single<PreferenceCardEntity> {
        return (NetworkManager.shared
            .request(ArchivingAPI.getPreferenceCard) as Single<PreferenceCardDTO>)
            .map { $0.mapping() }
    }
}

