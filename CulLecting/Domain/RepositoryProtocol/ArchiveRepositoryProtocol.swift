//
//  ArchiveRepositoryProtocol.swift
//  CulLecting
//
//  Created by 김승희 on 4/23/25.
//


import UIKit

import RxSwift

protocol ArchiveRepositoryProtocol {
    func uploadArchiving(dto: UploadArchivingRequestDTO) -> Completable
    func uploadArchiveImg(image: UIImage) -> Single<String>
    func fetchArchiving() -> Single<[Ticket]>
    func fetchTicket(id: String) -> Single<Ticket>
    func updateArchiving(dto: UpdateArchivingRequestDTO) -> Completable
    func updateImage(id: String, image: UIImage) -> Completable
    func updateTemplate(dto: UpdateTemplateRequestDTO) -> Completable
    func deleteArchiving(id: String) -> Completable
    func getPreferenceCard() -> Single<PreferenceCardEntity>
}
