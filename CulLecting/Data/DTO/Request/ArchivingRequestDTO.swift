//
//  UploadArchivingRequestDTO.swift
//  CulLecting
//
//  Created by 김승희 on 4/29/25.
//


import UIKit

struct UploadArchivingRequestDTO: Encodable {
    let image: Data
    let title: String
    let description: String
    let date: String
    let category: String
    let template: String
}

struct UpdateArchivingRequestDTO: Encodable {
    let id: String
    let title: String
    let description: String
    let date: String
    let category: String
}

struct UpdateImageRequestDTO: Encodable {
    let id: String
    let image: Data
}

struct UpdateTemplateRequestDTO: Encodable {
    let id: String
    let template: String
}

struct UploadArchiveImgResponseDTO: Decodable {
    let data: UploadArchiveImgDataDTO
}

struct UploadArchiveImgDataDTO: Decodable {
    let id: String
}

