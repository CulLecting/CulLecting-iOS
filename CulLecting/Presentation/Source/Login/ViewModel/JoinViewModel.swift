//
//  JoinViewModel.swift
//  CulLecting
//
//  Created by 김승희 on 4/19/25.
//


import Foundation

import RxCocoa
import RxSwift


final class JoinViewModel {

    struct Input {
        let email: Observable<String>
        let sendCodeTap: Observable<Void>
        let verificationCode: Observable<String>
        let verifyCodeTap: Observable<Void>
        let password: Observable<String>
        let confirmPassword: Observable<String>
        let nickname: Observable<String>
        let termsAccepted: Observable<Bool>
        let nextTap: Observable<Void>
    }

    struct Output {
        let isSendCodeEnabled: Driver<Bool>
        let isVerifyEnabled: Driver<Bool>
        let isNextEnabled: Driver<Bool>
        let joinResult: Driver<Result<Void, Error>>
    }

    private let authUseCase: AuthUseCase
    private let disposeBag = DisposeBag()
    private var verifiedToken: String? = nil

    init(useCase: AuthUseCase) {
        self.authUseCase = useCase
    }

    func transform(input: Input) -> Output {

        let isEmailValid = input.email
            .map { $0.contains("@") && $0.contains(".") }

        let isVerificationCodeEntered = input.verificationCode
            .map { !$0.isEmpty }

        let isPasswordConfirmed = Observable
            .combineLatest(input.password, input.confirmPassword)
            .map { $0 == $1 && !$0.isEmpty }

        let isNextEnabledObservable = Observable
            .combineLatest(
                input.nickname.map { !$0.isEmpty },
                isPasswordConfirmed,
                input.termsAccepted,
                Observable.just(verifiedToken != nil)
            )
            .map { $0.0 && $0.1 && $0.2 && $0.3 }

        // 이메일 인증 코드 요청
        input.sendCodeTap
            .withLatestFrom(input.email)
            .flatMapLatest { [weak self] email in
                self?.authUseCase.sendVerificationCode(email: email)
                    .asObservable()
                    .materialize() ?? Observable.empty()
            }
            .subscribe()
            .disposed(by: disposeBag)

        // 인증 코드 확인 후 토큰 저장
        input.verifyCodeTap
            .withLatestFrom(Observable.combineLatest(input.email, input.verificationCode))
            .flatMapLatest { [weak self] email, code in
                self?.authUseCase.verifyCode(email: email, code: code)
                    .asObservable()
                    .materialize() ?? Observable.empty()
            }
            .subscribe(onNext: { [weak self] event in
                if case let .next(token) = event {
                    self?.verifiedToken = token
                }
            })
            .disposed(by: disposeBag)

        // 회원가입 요청
        let joinResult = input.nextTap
            .withLatestFrom(Observable.combineLatest(input.email, input.password, input.nickname))
            .flatMapLatest { [weak self] email, password, nickname in
                guard let token = self?.verifiedToken else {
                    return Observable.just(Result<Void, Error>.failure(AuthError.tokenMissing))
                }

                return self?.authUseCase.signup(
                    email: email,
                    password: password,
                    nickname: nickname,
                    token: token
                )
                .andThen(Observable.just(Result<Void, Error>.success(())))
                .catch { error in Observable.just(Result<Void, Error>.failure(error)) } ?? Observable.empty()
            }
            .asDriver(onErrorJustReturn: .failure(AuthError.unknown))

        return Output(
            isSendCodeEnabled: isEmailValid.asDriver(onErrorJustReturn: false),
            isVerifyEnabled: isVerificationCodeEntered.asDriver(onErrorJustReturn: false),
            isNextEnabled: isNextEnabledObservable.asDriver(onErrorJustReturn: false),
            joinResult: joinResult
        )
    }
}

enum AuthError: Error {
    case tokenMissing
    case unknown
}
