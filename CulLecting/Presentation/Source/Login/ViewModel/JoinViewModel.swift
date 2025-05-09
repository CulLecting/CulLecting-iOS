//
//  JoinViewModel.swift
//  CulLecting
//
//  Created by 김승희 on 4/19/25.
//


import Foundation

import RxCocoa
import RxSwift

protocol JoinViewModelProtocol {
    func transform(input: JoinViewModel.Input) -> JoinViewModel.Output
}

final class JoinViewModel: JoinViewModelProtocol {

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
        let isVerifyEnabled: Driver<Bool>
        let isNextEnabled: Driver<Bool>
        let joinResult: Driver<Result<Void, Error>>
        let isEmailFormatValid: Observable<Bool>
        let emailSendResult: Signal<Bool>
        let emailVerified: Observable<Bool>
        let passwordMatchWarning: Observable<Bool>
    }

    private let verifiedToken = BehaviorRelay<String?>(value: nil)
    private let emailVerifiedRelay = BehaviorRelay<Bool>(value: false)
    private let emailSendResultRelay = PublishRelay<Bool>()
    private let passwordMismatchRelay = BehaviorRelay<Bool>(value: false)
    private let isVerifyButtonEnabled = BehaviorRelay<Bool>(value: false)
    public let sendCodeTapRelay = PublishRelay<Void>()
    
    var showVerificationFailedAlert: (() -> Void)?

    private let authUseCase: AuthUseCase
    private let disposeBag = DisposeBag()

    init(useCase: AuthUseCase) {
        self.authUseCase = useCase
    }

    func transform(input: Input) -> Output {
        let isEmailValid = input.email
            .map { email in
                let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
                return NSPredicate(format:"SELF MATCHES %@", regex).evaluate(with: email)
            }

        Observable.combineLatest(input.password, input.confirmPassword)
            .map { $0 != $1 || $0.isEmpty || $1.isEmpty }
            .bind(to: passwordMismatchRelay)
            .disposed(by: disposeBag)

        let isNextEnabled = Observable
            .combineLatest(
                input.nickname.map { !$0.isEmpty },
                passwordMismatchRelay.map { !$0 },
                input.termsAccepted,
                verifiedToken.map { $0 != nil }
            )
            .map { $0.0 && $0.1 && $0.2 && $0.3 }

        sendCodeTapRelay
            .withLatestFrom(Observable.combineLatest(input.email, isEmailValid))
            .flatMapLatest { [weak self] (email, isValid) -> Observable<Bool> in
                guard let self else { return .just(false) }
                guard isValid else { return .just(false) }

                return self.authUseCase.sendVerificationCode(email: email)
                    .andThen(.just(true))
                    .catchAndReturn(false)
            }
            .do(onNext: { [weak self] success in
                self?.isVerifyButtonEnabled.accept(success)
            })
            .bind(to: emailSendResultRelay)
            .disposed(by: disposeBag)

        input.verifyCodeTap
            .withLatestFrom(Observable.combineLatest(input.email, input.verificationCode))
            .flatMapLatest { [weak self] email, code in
                guard let self else { return Observable<Void>.empty() }
                return self.authUseCase.verifyCode(email: email, code: code)
                    .do(onSuccess: { token in
                        self.verifiedToken.accept(token)
                        self.emailVerifiedRelay.accept(true)
                    }, onError: { [weak self] _ in
                        self?.showVerificationFailedAlert?()
                    }
                    )
                    .map { _ in }
                    .asObservable()
                    .catchAndReturn(())
            }
            .subscribe()
            .disposed(by: disposeBag)

        let joinResult = input.nextTap
            .withLatestFrom(Observable.combineLatest(
                input.email,
                input.password,
                input.nickname,
                verifiedToken.asObservable()
            ))
            .flatMapLatest { [weak self] email, password, nickname, token in
                guard let self, let token else {
                    return Observable<Result<Void, Error>>.just(.failure(AuthError.tokenMissing))
                }

                return self.authUseCase.signup(
                    email: email,
                    password: password,
                    nickname: nickname,
                    token: token
                )
                .andThen(
                    self.authUseCase.login(email: email, password: password)
                        .do(onSuccess: { token in
                            TokenStorage.shared.accessToken = token.accessToken
                            TokenStorage.shared.refreshToken = token.refreshToken
                        })
                        .map { _ in Result<Void, Error>.success(()) }
                        .catch { error in .just(.failure(error)) }
                        .asObservable()
                )
            }
            .asDriver(onErrorJustReturn: .failure(AuthError.tokenMissing))

        return Output(
            isVerifyEnabled: isVerifyButtonEnabled.asDriver(onErrorJustReturn: false),
            isNextEnabled: isNextEnabled.asDriver(onErrorJustReturn: false),
            joinResult: joinResult,
            isEmailFormatValid: isEmailValid,
            emailSendResult: emailSendResultRelay.asSignal(),
            emailVerified: emailVerifiedRelay.asObservable(),
            passwordMatchWarning: passwordMismatchRelay.asObservable()
        )
    }
}


enum AuthError: Error {
    case tokenMissing
}
