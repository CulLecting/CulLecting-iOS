//
//  LoginViewModel.swift
//  CulLecting
//
//  Created by 김승희 on 3/27/25.
//

import Foundation

import RxCocoa
import RxSwift


final class LoginViewModel {

    // MARK: - Input & Output
    struct Input {
        let email: Observable<String>
        let password: Observable<String>
        let loginTap: Observable<Void>
    }

    struct Output {
        let loginResult: Driver<Result<TokenDTO, Error>>
    }

    // MARK: - Dependencies
    private let authUseCase: AuthUseCase
    private let disposeBag = DisposeBag()

    init(authUseCase: AuthUseCase) {
        self.authUseCase = authUseCase
    }

    func transform(input: Input) -> Output {
        let result = input.loginTap
            .withLatestFrom(Observable.combineLatest(input.email, input.password))
            .flatMapLatest { [weak self] email, password -> Observable<Result<TokenDTO, Error>> in
                guard let self = self else { return .empty() }
                return self.authUseCase.login(email: email, password: password)
                    .map { .success($0) }
                    .catch { .just(.failure($0)) }
                    .asObservable()
            }
            .asDriver(onErrorDriveWith: .empty())

        return Output(loginResult: result)
    }
}
