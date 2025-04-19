//
//  UserDTO+Mapping.swift
//  CulLecting
//
//  Created by 김승희 on 3/27/25.
//


import Foundation

public struct UserDTO: Decodable {
    public let id: String
    public let email: String
    public let nickname: String
    public let location: [String]?
    public let category: [String]?

    public func mapping() -> UserEntity {
        return UserEntity(
            id: id,
            email: email,
            nickName: nickname,
            location: location,
            category: category
        )
    }
}
