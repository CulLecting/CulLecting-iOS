//
//  CulturalEntity.swift
//  CulLecting
//
//  Created by 김승희 on 4/29/25.
//


import Foundation


struct CulturalImageEntity {
    let title: String
    let imageURL: String
}

struct CulturalContentEntity {
    let id: Int
    let title: String
    let imageURL: String
    let place: String
    let startDate: String?
    let endDate: String?
}

struct CulturalDetailEntity {
    let id: Int
    let title: String
    let codename: String
    let guname: String
    let place: String
    let orgName: String
    let orgLink: String
    let mainImg: String
    let themeCode: String
    let startDate: String
    let endDate: String
    let date: String
    let lot: String
    let lat: String
    let hmpgAddr: String
    let lastUpdated: String
    let free: Bool
}
