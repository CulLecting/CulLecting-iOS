//
//  TicketEntity.swift
//  CulLecting
//
//  Created by 김승희 on 4/15/25.
//


import Foundation

struct Ticket: Identifiable, Codable, Equatable {
    let id: UUID
    let attendAt: Date
    let poster: String
    let averageColorHex: String
    let backText: String
}
