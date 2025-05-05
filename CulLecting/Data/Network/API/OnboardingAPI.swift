//
//  Untitled.swift
//  CulLecting
//
//  Created by 김승희 on 4/22/25.
//


import Foundation

import Alamofire


enum OnboardingAPI: URLRequestConvertible {
    case updateOnboarding(OnboardingRequestDTO)
    
    var method: HTTPMethod {
        switch self {
        case .updateOnboarding:
            return .post
        }
    }
    
    var path: String {
        switch self {
        case .updateOnboarding:
            return "/member/onboarding"
        }
    }
    
    var headers: HTTPHeaders {
        var headers: HTTPHeaders = [
            APIConstants.HeaderKey.contentType: APIConstants.HeaderValue.json
        ]
        
        if let token = TokenStorage.shared.accessToken {
            headers.add(name: APIConstants.HeaderKey.authorization, value: "Bearer \(token)")
        }
        return headers
    }
    
    var body: Data? {
        switch self {
        case let .updateOnboarding(dto):
            return try? JSONEncoder().encode(dto)
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        let url = URL(string: APIConstants.baseURL)!.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.method = method
        request.headers = headers
        
        if let body = body {
            request.httpBody = body
        }
        return request
    }
}
