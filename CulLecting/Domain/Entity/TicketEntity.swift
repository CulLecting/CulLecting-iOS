//
//  ArchivingEntity.swift
//  CulLecting
//
//  Created by 김승희 on 4/23/25.
//


struct Ticket: Codable {
    let id: String
    let title: String
    let description: String
    let date: String
    let imageURL: String
    let category: String
    let template: String
    let averageColorHex: String
}
