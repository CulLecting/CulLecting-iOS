//
//  AuthUsecase.swift
//  CulLecting
//
//  Created by 김승희 on 3/27/25.
//

import UIKit

import RxSwift

public protocol AuthUsecaseProtocol {
    func login(email: String, password: String) -> Single<TokenDTO>
    func signup(email: String, password: String, nickname: String) -> Completable
    func fetchUserInfo() -> Single<UserEntity>
    func refreshToken() -> Single<TokenDTO>
    func sendVerificationCode(email: String) -> Completable
    func verifyCode(email: String, code: String) -> Single<String> // 토큰 반환
    func updateOnboarding(location: [String], category: [String]) -> Completable
    func resetPassword(email: String) -> Completable
    func confirmResetPassword(email: String, newPassword: String) -> Completable
    func changePassword(before: String, new: String) -> Completable
    func logout() -> Completable
    func deleteAccount() -> Completable
}

public final class AuthUseCase: AuthUsecaseProtocol {
    private let repository: AuthRepositoryProtocol
    public init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }

    public func login(email: String, password: String) -> Single<TokenDTO> {
        repository.login(email: email, password: password)
    }

    public func signup(email: String, password: String, nickname: String) -> Completable {
        repository.signup(email: email, password: password, nickname: nickname)
    }

    public func fetchUserInfo() -> Single<UserEntity> {
        repository.fetchUserInfo()
    }

    public func refreshToken() -> Single<TokenDTO> {
        repository.refreshToken()
    }

    public func sendVerificationCode(email: String) -> Completable {
        repository.sendVerificationCode(email: email)
    }

    public func verifyCode(email: String, code: String) -> Single<String> {
        repository.verifyCode(email: email, code: code)
    }

    public func updateOnboarding(location: [String], category: [String]) -> Completable {
        repository.updateOnboarding(location: location, category: category)
    }

    public func resetPassword(email: String) -> Completable {
        repository.resetPassword(email: email)
    }

    public func confirmResetPassword(email: String, newPassword: String) -> Completable {
        repository.confirmResetPassword(email: email, newPassword: newPassword)
    }

    public func changePassword(before: String, new: String) -> Completable {
        repository.changePassword(before: before, new: new)
    }

    public func logout() -> Completable {
        repository.logout()
    }

    public func deleteAccount() -> Completable {
        repository.deleteAccount()
    }
}

