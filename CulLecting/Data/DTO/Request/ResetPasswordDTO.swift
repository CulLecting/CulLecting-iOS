//
//  ResetPasswordDTO.swift
//  CulLecting
//
//  Created by 김승희 on 4/16/25.
//


public struct ResetPasswordDTO: Codable, Sendable {
    public let email: String
    public let newPassword: String

    public init(email: String, newPassword: String) {
        self.email = email
        self.newPassword = newPassword
    }
}
