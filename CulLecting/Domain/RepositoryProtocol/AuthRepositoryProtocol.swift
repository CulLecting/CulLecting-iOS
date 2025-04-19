//
//  AuthRepositoryProtocol.swift
//  CulLecting
//
//  Created by 김승희 on 3/27/25.
//


import UIKit

import RxSwift


public protocol AuthRepositoryProtocol {
    func login(email: String, password: String) -> Single<TokenDTO>
    func signup(email: String, password: String, nickname: String, token: String) -> Completable
    func fetchUserInfo() -> Single<UserEntity>
    func refreshToken() -> Single<TokenDTO>
    func sendVerificationCode(email: String) -> Completable
    func verifyCode(email: String, code: String) -> Single<String>
    func updateOnboarding(location: [String], category: [String]) -> Completable
    func resetPassword(email: String) -> Completable
    func confirmResetPassword(email: String, newPassword: String, token: String) -> Completable
    func changePassword(before: String, new: String) -> Completable
    func logout() -> Completable
    func deleteAccount() -> Completable
}
