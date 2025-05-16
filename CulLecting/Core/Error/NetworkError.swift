//
//  NetworkError.swift
//  CulLecting
//
//  Created by 김승희 on 4/16/25.
//


import Foundation


public enum NetworkError: Error {
    case serverMessage(String)
    case tokenExpired(String)
    case decodingError
    case invalidImageData
    case unknown
    case noData

    public var message: String {
        switch self {
        case .serverMessage(let msg): return msg
        case .tokenExpired(let msg): return msg
        case .decodingError: return "응답을 해석할 수 없습니다."
        case .unknown: return "알 수 없는 오류가 발생했습니다. 관리자에게 문의하세요."
        case .invalidImageData: return "이미지 데이터 오류"
        case .noData: return "데이터가 없습니다."
        }
    }
}

extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        return self.message
    }
}
