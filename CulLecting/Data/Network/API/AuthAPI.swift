//
//  AuthAPI.swift
//  CulLecting
//
//  Created by 김승희 on 4/15/25.
//


import Foundation

import Alamofire

enum AuthAPI: URLRequestConvertible {
    case login(email: String, password: String)
    case signup(dto: SignUpDTO, token: String)
    case userInfo
    case refreshToken
    case sendVerificationCode(email: String)
    case verifyCode(email: String, code: String)
    case resetPassword(email: String)
    case confirmResetPassword(dto: ResetPasswordDTO, token: String)
    case changePassword(before: String, new: String)
    case logout
    case deleteAccount

    var method: HTTPMethod {
        switch self {
        case .userInfo:
            return .get
        default:
            return .post
        }
    }

    var path: String {
        switch self {
        case .login: return "/member/login"
        case .signup: return "/member" // 기존 /member/signup → /member
        case .userInfo: return "/member/me"
        case .refreshToken: return "/member/token/refresh"
        case .sendVerificationCode: return "/member/email-verifications"
        case .verifyCode: return "/member/email-verifications/verify"
        case .resetPassword: return "/member/password/reset-request"
        case .confirmResetPassword: return "/member/password"
        case .changePassword: return "/member/mypage/password"
        case .logout: return "/member/logout"
        case .deleteAccount: return "/member"
        }
    }

    var headers: HTTPHeaders {
        // 기본 헤더
        var headers: HTTPHeaders = [
            APIConstants.HeaderKey.contentType: APIConstants.HeaderValue.json
        ]

        //추가 헤더
        switch self {
        case .signup(_, let token),
                .confirmResetPassword(_, let token):
            headers.add(name: APIConstants.HeaderKey.authorization, value: "Bearer \(token)")
            
        case .userInfo, .changePassword, .logout, .deleteAccount:
            if let token = TokenStorage.shared.accessToken {
                headers.add(name: APIConstants.HeaderKey.authorization, value: "Bearer \(token)")
            }
            
        case .refreshToken:
            if let token = TokenStorage.shared.refreshToken {
                headers.add(name: APIConstants.HeaderKey.authorization, value: "Bearer \(token)")
            }
            
        default:
            break
        }
        return headers
    }

    var parameters: Parameters? {
        switch self {
        case let .login(email, password):
            return ["email": email, "password": password]

        case let .sendVerificationCode(email):
            return ["email": email]

        case let .verifyCode(email, code):
            return ["email": email, "code": code]

        case let .changePassword(before, new):
            return ["before": before, "new": new]

        case let .resetPassword(email):
            return ["email": email]

        default:
            return nil
        }
    }

    var body: Data? {
        switch self {
        case let .signup(dto, _):
            return try? JSONEncoder().encode(dto)

        case let .confirmResetPassword(dto, _):
            return try? JSONEncoder().encode(dto)

        default:
            return nil
        }
    }

    func asURLRequest() throws -> URLRequest {
        let url = URL(string: APIConstants.baseURL + path)!
        var request = URLRequest(url: url)
        request.method = method
        request.headers = headers

        if let params = parameters {
            request.httpBody = try? JSONSerialization.data(withJSONObject: params)
        } else if let body = body {
            request.httpBody = body
        }
        return request
    }
}
