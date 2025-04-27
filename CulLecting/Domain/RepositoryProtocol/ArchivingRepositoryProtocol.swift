//
//  ArchivingRepositoryProtocol.swift
//  CulLecting
//
//  Created by 김승희 on 4/23/25.
//


import UIKit

import RxSwift

protocol ArchivingRepositoryProtocol {
    func uploadArchiving(image: UIImage, title: String, description: String, date: String, category: String, template: String) -> Completable
    func fetchArchiving() -> Single<[Ticket]>
    func deleteArchiving(id: String) -> Completable
    func updateArchiving(id: String, title: String, description: String, date: String, category: String) -> Completable
    func updateImage(id: String, image: UIImage) -> Completable
    func updateTemplate(id: String, template: String) -> Completable
    func getPreferenceCard() -> Single<PreferenceCardEntity>
}
