//
//  ResetPasswordViewModel.swift
//  CulLecting
//
//  Created by 김승희 on 5/9/25.
//


import Foundation

import RxCocoa
import RxSwift


final class ResetPasswordViewModel {
    
    struct Input {
        let email: Observable<String>
        let sendCodeTap: Observable<Void>
        let verificationCode: Observable<String>
        let verifyCodeTap: Observable<Void>
        let password: Observable<String>
        let confirmPassword: Observable<String>
        let resetTap: Observable<Void>
    }

    struct Output {
        let isVerifyEnabled: Driver<Bool>
        let isNextEnabled: Driver<Bool>
        let resetResult: Driver<Result<Void, Error>>
        let isEmailFormatValid: Observable<Bool>
        let emailSendResult: Signal<Bool>
        let emailVerified: Observable<Bool>
        let passwordMatchWarning: Observable<Bool>
    }

    // MARK: 상태
    private let verifiedToken = BehaviorRelay<String?>(value: nil)
    private let emailVerifiedRelay = BehaviorRelay<Bool>(value: false)
    private let emailSendResultRelay = PublishRelay<Bool>()
    private let passwordMismatchRelay = BehaviorRelay<Bool>(value: false)
    private let isVerifyButtonEnabled = BehaviorRelay<Bool>(value: false)
    
    var showVerificationFailedAlert: (() -> Void)?

    private let authUseCase: AuthUseCaseProtocol
    private let disposeBag = DisposeBag()

    init(useCase: AuthUseCaseProtocol) {
        self.authUseCase = useCase
    }

    func transform(input: Input) -> Output {
        let isEmailValid = input.email
            .map { email in
                let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
                return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
            }

        // 비밀번호 불일치 여부 감지
        Observable.combineLatest(input.password, input.confirmPassword)
            .map { $0 != $1 || $0.isEmpty || $1.isEmpty }
            .bind(to: passwordMismatchRelay)
            .disposed(by: disposeBag)

        // "확인" 버튼 활성화 조건
        let isNextEnabled = Observable
            .combineLatest(
                passwordMismatchRelay.map { !$0 },
                verifiedToken.map { $0 != nil }
            )
            .map { $0.0 && $0.1 }
            .asDriver(onErrorJustReturn: false)

        // 인증 요청 처리
        input.sendCodeTap
            .withLatestFrom(Observable.combineLatest(input.email, isEmailValid))
            .flatMapLatest { [weak self] email, isValid -> Observable<Bool> in
                guard let self, isValid else { return .just(false) }

                return self.authUseCase.resetPassword(email: email)
                    .andThen(.just(true))
                    .catchAndReturn(false)
            }
            .do(onNext: { [weak self] success in
                self?.isVerifyButtonEnabled.accept(success)
            })
            .bind(to: emailSendResultRelay)
            .disposed(by: disposeBag)

        // 인증번호 확인
        input.verifyCodeTap
            .withLatestFrom(Observable.combineLatest(input.email, input.verificationCode))
            .flatMapLatest { [weak self] email, code in
                guard let self else { return Observable<Void>.empty() }

                return self.authUseCase.verifyCode(email: email, code: code)
                    .do(
                        onSuccess: { token in
                            self.verifiedToken.accept(token)
                            self.emailVerifiedRelay.accept(true)
                        },
                        onError: { [weak self] _ in
                            self?.showVerificationFailedAlert?()
                        }
                    )
                    .map { _ in }
                    .asObservable()
                    .catchAndReturn(())
            }
            .subscribe()
            .disposed(by: disposeBag)

        // 비밀번호 재설정 요청
        let resetResult = input.resetTap
            .withLatestFrom(Observable.combineLatest(input.email, input.password, input.confirmPassword, verifiedToken.asObservable()))
            .filter { email, pw, confirm, token in
                pw == confirm && !pw.isEmpty && token != nil
            }
            .flatMapLatest { [weak self] email, password, _, token in
                guard let self, let token else {
                    return Observable<Result<Void, Error>>.just(.failure(AuthError.tokenMissing))
                }

                return self.authUseCase.confirmResetPassword(email: email, newPassword: password, token: token)
                    .andThen(.just(.success(())))
                    .catch { error in .just(.failure(error)) }
            }
            .asDriver(onErrorJustReturn: .failure(AuthError.tokenMissing))

        return Output(
            isVerifyEnabled: isVerifyButtonEnabled.asDriver(onErrorJustReturn: false),
            isNextEnabled: isNextEnabled,
            resetResult: resetResult,
            isEmailFormatValid: isEmailValid,
            emailSendResult: emailSendResultRelay.asSignal(),
            emailVerified: emailVerifiedRelay.asObservable(),
            passwordMatchWarning: passwordMismatchRelay.asObservable()
        )
    }
}
