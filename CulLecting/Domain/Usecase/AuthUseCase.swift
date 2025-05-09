//
//  AuthUsecase.swift
//  CulLecting
//
//  Created by 김승희 on 3/27/25.
//

import UIKit

import RxSwift

public protocol AuthUseCaseProtocol {
    func login(email: String, password: String) -> Single<TokenDTO>
    func signup(email: String, password: String, nickname: String, token: String) -> Completable
    func fetchUserInfo() -> Single<UserEntity>
    func refreshToken() -> Single<TokenDTO>
    func sendVerificationCode(email: String) -> Completable
    func verifyCode(email: String, code: String) -> Single<String>
    func resetPassword(email: String) -> Completable
    func confirmResetPassword(email: String, newPassword: String, token: String) -> Completable
    func changePassword(before: String, new: String) -> Completable
    func logout() -> Completable
    func deleteAccount() -> Completable
}

public final class AuthUseCase: AuthUseCaseProtocol {
    private let repository: AuthRepositoryProtocol
    
    public init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }
    
    public func login(email: String, password: String) -> Single<TokenDTO> {
        repository.login(email: email, password: password)
            .do(onSuccess: { token in
                TokenStorage.shared.accessToken = token.accessToken
                TokenStorage.shared.refreshToken = token.refreshToken
            })
    }
    
    public func signup(email: String, password: String, nickname: String, token: String) -> Completable {
        repository.signup(email: email, password: password, nickname: nickname, token: token)
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
    
    public func resetPassword(email: String) -> Completable {
        print("resetpassword usecase Called")
        return repository.resetPassword(email: email)
    }
    
    public func confirmResetPassword(email: String, newPassword: String, token: String) -> Completable {
        repository.confirmResetPassword(email: email, newPassword: newPassword, token: token)
    }
    
    public func changePassword(before: String, new: String) -> Completable {
        repository.changePassword(before: before, new: new)
    }
    
    public func logout() -> Completable {
        return repository.logout()
            .do(onCompleted: {
                TokenStorage.shared.clearAll()
            })
    }
    
    public func deleteAccount() -> Completable {
        repository.deleteAccount()
            .do(onCompleted: {
                UserDefaults.standard.set(false, forKey: "hasSeenOnboarding")
                UserDefaults.standard.synchronize()
                TokenStorage.shared.clearAll()
            })
    }
}
