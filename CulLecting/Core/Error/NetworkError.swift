//
//  NetworkError.swift
//  CulLecting
//
//  Created by 김승희 on 4/16/25.
//


public enum NetworkError: Error {
    case serverMessage(String)
    case decodingError
    case unknown

    public var message: String {
        switch self {
        case .serverMessage(let msg): return msg
        case .decodingError: return "응답을 해석할 수 없습니다."
        case .unknown: return "알 수 없는 오류가 발생했습니다. 관리자에게 문의하세요."
        }
    }
}
