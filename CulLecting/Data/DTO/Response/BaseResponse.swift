//
//  BaseResponse.swift
//  CulLecting
//
//  Created by 김승희 on 4/15/25.
//


public struct BaseResponse<T: Decodable>: Decodable {
    public let status: Int
    public let message: String
    public let data: T!
}
