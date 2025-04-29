//
//  ArchivingDTO.swift
//  CulLecting
//
//  Created by 김승희 on 4/29/25.
//


struct ArchivingDTO: Decodable {
    let id: String
    let title: String
    let description: String
    let date: String
    let imageURL: String
    let category: String
    let template: String
}

extension ArchivingDTO {
    func mapping() -> Ticket {
        return Ticket(
            id: id,
            title: title,
            description: description,
            date: date,
            imageURL: imageURL,
            category: category,
            template: template,
            averageColorHex: "#FFFFFF" // 서버가 안주니까 기본값 세팅
        )
    }
}
