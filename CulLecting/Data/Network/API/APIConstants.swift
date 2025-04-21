//
//  APIConstants.swift
//  CulLecting
//
//  Created by 김승희 on 4/22/25.
//


enum APIConstants {
    static let baseURL = "https://cullecting.site"

    enum Path {
        static let login = "/member/login"
        static let signup = "/member/signup"
        static let userInfo = "/member/userinfo"
        static let refreshToken = "/member/refreshtoken"
        static let sendVerificationCode = "/member/send"
        static let verifyCode = "/member/verify"
        static let updateOnboarding = "/member/onboarding"
        static let resetPassword = "/member/login/resetpassword"
        static let confirmResetPassword = "/member/passwordupdate"
        static let changePassword = "/member/mypage/passwordreset"
        static let logout = "/member/logout"
        static let deleteAccount = "/member/deletemember"
    }

    enum HeaderKey {
        static let contentType = "Content-Type"
        static let authorization = "Authorization"
    }

    enum HeaderValue {
        static let json = "application/json"
    }
}
