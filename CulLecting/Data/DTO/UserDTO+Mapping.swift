//
//  UserDTO+Mapping.swift
//  CulLecting
//
//  Created by 김승희 on 3/27/25.
//

import Foundation

public struct UserDTO: Codable {
    let email: String
    let nickName: String
    
    func mapping() -> UserEntity {
        return UserEntity(email: email, nickName: nickName)
    }
}
