//
//  SignUpDTO.swift
//  CulLecting
//
//  Created by 김승희 on 3/27/25.
//


public struct SignUpDTO: Codable, Sendable {
    let email: String
    let password: String
    let nickName: String
    let token: String
}
