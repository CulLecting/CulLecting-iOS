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
    case updateOnboarding(OnboardingRequestDTO)
    case resetPassword(email: String)
    case confirmResetPassword(dto: ResetPasswordDTO, token: String)
    case changePassword(before: String, new: String)
    case logout
    case deleteAccount

    var method: HTTPMethod {
        switch self {
        case .userInfo: return .get
        default: return .post
        }
    }

    var path: String {
        switch self {
        case .login: return "/member/login"
        case .signup: return "/member/signup"
        case .userInfo: return "/member/userinfo"
        case .refreshToken: return "/member/refreshtoken"
        case .sendVerificationCode: return "/member/send"
        case .verifyCode: return "/member/verify"
        case .updateOnboarding: return "/member/onboarding"
        case .resetPassword: return "/member/login/resetpassword"
        case .confirmResetPassword: return "/member/passwordupdate"
        case .changePassword: return "/member/mypage/passwordreset"
        case .logout: return "/member/logout"
        case .deleteAccount: return "/member/deletemember"
        }
    }

    var headers: HTTPHeaders {
        var headers: HTTPHeaders = ["Content-Type": "application/json"]

        switch self {
        case .signup(_, let token), .confirmResetPassword(_, let token):
            headers.add(name: "Authorization", value: token)
            
        case .userInfo, .updateOnboarding, .changePassword, .logout, .deleteAccount:
            if let token = TokenStorage.shared.accessToken {
                headers.add(name: "Authorization", value: token)
            }
            
        case .refreshToken:
            if let token = TokenStorage.shared.refreshToken {
                headers.add(name: "Authorization", value: token)
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
            
        default:
            return nil
        }
    }

    var body: Data? {
        switch self {
        case let .signup(dto: dto, _):
            return try? JSONEncoder().encode(dto)
            
        case let .updateOnboarding(dto):
            return try? JSONEncoder().encode(dto)
            
        case let .confirmResetPassword(dto: dto, _):
            return try? JSONEncoder().encode(dto)
            
        default:
            return nil
        }
    }


    func asURLRequest() throws -> URLRequest {
        let baseURL = URL(string: "https://puppyting.site")!
        let url = baseURL.appendingPathComponent(path)

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
