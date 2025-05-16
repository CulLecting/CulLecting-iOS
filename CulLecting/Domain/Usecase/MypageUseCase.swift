//
//  MypageUseCase.swift
//  CulLecting
//
//  Created by 김승희 on 4/27/25.
//


import Foundation

import RxSwift


protocol MypageUseCaseProtocol {
    func fetchUser() -> Single<UserEntity>
    func logout() -> Completable
    func deleteAccount() -> Completable
}


final class MypageUseCase: MypageUseCaseProtocol {

    private let authRepository: AuthRepositoryProtocol

    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }

    func fetchUser() -> Single<UserEntity> {
        return authRepository.fetchUserInfo()
    }

    func logout() -> Completable {
        return authRepository.logout()
    }

    func deleteAccount() -> Completable {
        return authRepository.deleteAccount()
    }
}
