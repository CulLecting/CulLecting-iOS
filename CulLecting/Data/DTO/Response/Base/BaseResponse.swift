//
//  BaseResponse.swift
//  CulLecting
//
//  Created by 김승희 on 4/15/25.
//


public struct BaseResponse<T: Decodable>: Decodable {
    public let status: Int
    public let message: String
    public let data: T?

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        status = try container.decode(Int.self, forKey: .status)
        message = try container.decode(String.self, forKey: .message)

        if T.self is [Any].Type {
            data = try container.decodeIfPresent(T.self, forKey: .data) ?? ([] as! T)
        } else {
            data = try container.decodeIfPresent(T.self, forKey: .data)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case status
        case message
        case data
    }
}
