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
    
    // MARK: Input / Output
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
        let emailSendResult: Signal<Bool>
        let emailVerified: Observable<Bool>
        let passwordMatchWarning: Observable<Bool>
    }

    // MARK: 내부 상태
    private let verifiedToken = BehaviorRelay<String?>(value: nil)
    private let emailVerifiedRelay = BehaviorRelay<Bool>(value: false)
    private let emailSendResultRelay = PublishRelay<Bool>()
    private let passwordMismatchRelay = BehaviorRelay<Bool>(value: false)

    private let authUseCase: AuthUseCase
    private let disposeBag = DisposeBag()

    init(useCase: AuthUseCase) {
        self.authUseCase = useCase
    }

    func transform(input: Input) -> Output {
        let isEmailValid = input.email
            .map { $0.contains("@") && $0.contains(".") }

        let isVerificationCodeEntered = input.verificationCode
            .map { !$0.isEmpty }

        // 비밀번호 일치 여부 판단
        Observable.combineLatest(input.password, input.confirmPassword)
            .map { $0 != $1 || $0.isEmpty || $1.isEmpty }
            .bind(to: passwordMismatchRelay)
            .disposed(by: disposeBag)

        // 다음 버튼 활성화 조건
        let isNextEnabled = Observable
            .combineLatest(
                input.nickname.map { !$0.isEmpty },
                passwordMismatchRelay.map { !$0 }, // 비밀번호 일치할 때만 true
                input.termsAccepted,
                verifiedToken.map { $0 != nil }
            )
            .map { $0.0 && $0.1 && $0.2 && $0.3 }

        // 이메일 인증 코드 요청
        input.sendCodeTap
            .withLatestFrom(input.email)
            .flatMapLatest { [weak self] email -> Observable<Bool> in
                guard let self else { return .just(false) }
                guard email.contains("@"), email.contains(".") else { return .just(false) }

                return self.authUseCase.sendVerificationCode(email: email)
                    .andThen(.just(true))
                    .catchAndReturn(false)
            }
            .bind(to: emailSendResultRelay)
            .disposed(by: disposeBag)

        // 인증번호 확인
        input.verifyCodeTap
            .withLatestFrom(Observable.combineLatest(input.email, input.verificationCode))
            .flatMapLatest { [weak self] email, code in
                guard let self else { return Observable<Void>.empty() }
                return self.authUseCase.verifyCode(email: email, code: code)
                    .do(onSuccess: { token in
                        self.verifiedToken.accept(token)
                        self.emailVerifiedRelay.accept(true)
                    })
                    .map { _ in }
                    .asObservable()
                    .catchAndReturn(())
            }
            .subscribe()
            .disposed(by: disposeBag)

        // 회원가입 요청
        let joinResult = input.nextTap
            .withLatestFrom(Observable.combineLatest(input.email,
                                                     input.password,
                                                     input.nickname,
                                                     verifiedToken.asObservable()))
            .flatMapLatest { [weak self] email, password, nickname, token in
                guard let self,
                      let token = self.verifiedToken.value else {
                    print("joinviewmodel: 토큰값이 없음")
                    return Observable.just(Result<Void, Error>.failure(AuthError.tokenMissing))
                }
                
                print("회원가입 요청: \(email), \(password), \(nickname), \(token)")
                
                return self.authUseCase.signup(
                    email: email,
                    password: password,
                    nickname: nickname,
                    token: token
                )
                .andThen(.just(.success(())))
                .catch { error in
                    print("JoinViewModel 가입 실패: \(error.localizedDescription)")
                    return .just(.failure(error)) }
            }
            .asDriver(onErrorJustReturn: .failure(AuthError.tokenMissing))

        return Output(
            isSendCodeEnabled: isEmailValid.asDriver(onErrorJustReturn: false),
            isVerifyEnabled: isVerificationCodeEntered.asDriver(onErrorJustReturn: false),
            isNextEnabled: isNextEnabled.asDriver(onErrorJustReturn: false),
            joinResult: joinResult,
            emailSendResult: emailSendResultRelay.asSignal(),
            emailVerified: emailVerifiedRelay.asObservable(),
            passwordMatchWarning: passwordMismatchRelay.asObservable()
        )
    }
}

enum AuthError: Error {
    case tokenMissing
}
