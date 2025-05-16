//
//  ArchivingEntity.swift
//  CulLecting
//
//  Created by 김승희 on 4/23/25.
//


import UIKit


struct Ticket: Codable {
    let id: String
    let title: String
    let description: String
    let date: String
    let imageURL: String
    let category: String
    let template: TemplateType
    let averageColorHex: String
}

enum TemplateType: String, Codable {
    case basic = "DEFAULT"
    case black
    case white
    case grid
    case floral
    case cloud
    case swirl
}

extension Ticket {
    func updated(title: String, description: String, date: String, category: String) -> Ticket {
        return Ticket(
            id: self.id,
            title: title,
            description: description,
            date: date,
            imageURL: self.imageURL,
            category: category,
            template: self.template,
            averageColorHex: self.averageColorHex
        )
    }
}
