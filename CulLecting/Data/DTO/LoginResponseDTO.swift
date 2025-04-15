//
//  LoginResponseDTO.swift
//  CulLecting
//
//  Created by 김승희 on 3/27/25.
//

public struct LoginResponseDTO: Decodable {
    let accessToken: String
    let refreshToken: String
    
    // Token Mapping Logic 필요 - 어떻게 할지 정하고 나서
}
