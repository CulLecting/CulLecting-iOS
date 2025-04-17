//
//  AuthRepository.swift
//  CulLecting
//
//  Created by 김승희 on 4/15/25.
//


import UIKit

import Alamofire
import RxSwift


final class AuthRepository: AuthRepositoryProtocol {
    
    // MARK: - Init
    init() {}

    // MARK: - AuthRepositoryProtocol

    func login(email: String, password: String) -> Single<TokenDTO> {
        return NetworkManager.shared.request(AuthAPI.login(email: email, password: password))
    }

    func signup(email: String, password: String, nickname: String, token: String) -> Completable {
        let dto = SignUpDTO(email: email, password: password, nickName: nickname, token: token)
        return NetworkManager.shared
            .requestWithoutData(AuthAPI.signup(dto: dto, token: token))
    }

    func fetchUserInfo() -> Single<UserEntity> {
        return (NetworkManager.shared
            .request(AuthAPI.userInfo) as Single<UserDTO>)
            .map { $0.mapping() }
    }

    func refreshToken() -> Single<TokenDTO> {
        return NetworkManager.shared.request(AuthAPI.refreshToken)
    }

    func sendVerificationCode(email: String) -> Completable {
        return NetworkManager.shared
            .requestWithoutData(AuthAPI.sendVerificationCode(email: email))
    }

    func verifyCode(email: String, code: String) -> Single<String> {
        return (NetworkManager.shared
            .request(AuthAPI.verifyCode(email: email, code: code)) as Single<VerifyCodeResponseDTO>)
            .map { $0.token }
    }

    func updateOnboarding(location: [String], category: [String]) -> Completable {
        let dto = OnboardingRequestDTO(location: location, category: category)
        return NetworkManager.shared
            .requestWithoutData(AuthAPI.updateOnboarding(dto))
    }

    func resetPassword(email: String) -> Completable {
        return NetworkManager.shared
            .requestWithoutData(AuthAPI.resetPassword(email: email))
    }

    func confirmResetPassword(email: String, newPassword: String, token: String) -> Completable {
        let dto = ResetPasswordDTO(email: email, newPassword: newPassword)
        return NetworkManager.shared
            .requestWithoutData(AuthAPI.confirmResetPassword(dto: dto, token: token))
    }

    func changePassword(before: String, new: String) -> Completable {
        return NetworkManager.shared
            .requestWithoutData(AuthAPI.changePassword(before: before, new: new))
    }

    func logout() -> Completable {
        return NetworkManager.shared
            .requestWithoutData(AuthAPI.logout)
    }

    func deleteAccount() -> Completable {
        return NetworkManager.shared
            .requestWithoutData(AuthAPI.deleteAccount)
    }
}
