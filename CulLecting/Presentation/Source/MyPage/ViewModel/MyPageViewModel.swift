//
//  MyPageViewModel.swift
//  CulLecting
//
//  Created by 김승희 on 4/13/25.
//


import UIKit

import RxSwift
import RxCocoa


final class MypageViewModel {
    private let useCase: MypageUseCase
    private let authUseCase: AuthUseCaseProtocol
    private let disposeBag = DisposeBag()

    struct Input {
        let logoutTrigger: Observable<Void>
        let deleteTrigger: Observable<Void>
    }

    struct Output {
        let nickname: Driver<String>
        let logoutCompleted: Signal<Void>
        let deleteCompleted: Signal<Void>
        let isLoggedIn: Driver<Bool>
    }

    init(useCase: MypageUseCase, authUseCase: AuthUseCaseProtocol) {
        self.useCase = useCase
        self.authUseCase = authUseCase
    }
    
    func transform(input: Input) -> Output {
        let nicknameRelay = BehaviorRelay<String>(value: "")
        let logoutRelay = PublishRelay<Void>()
        let deleteRelay = PublishRelay<Void>()
        
        useCase.fetchUser()
            .map { $0.nickName }
            .subscribe(onSuccess: { nickname in
                nicknameRelay.accept(nickname)
            })
            .disposed(by: disposeBag)
        
        input.logoutTrigger
            .flatMapLatest { [weak self] _ -> Observable<Void> in
                guard let self else { return .empty() }
                return self.useCase.logout()
                    .andThen(.just(()))
            }
            .subscribe(onNext: {
                logoutRelay.accept(())
            })
            .disposed(by: disposeBag)
        
        input.deleteTrigger
            .flatMapLatest { [weak self] _ -> Observable<Void> in
                guard let self else { return .empty() }
                return self.useCase.deleteAccount()
                    .andThen(.just(()))
            }
            .subscribe(onNext: {
                deleteRelay.accept(())
            })
            .disposed(by: disposeBag)
        
        
        let isLoggedIn = Driver.just(authUseCase.isLoggedIn)

        return Output(
            nickname: nicknameRelay.asDriver(),
            logoutCompleted: logoutRelay.asSignal(),
            deleteCompleted: deleteRelay.asSignal(),
            isLoggedIn: isLoggedIn
        )
    }
}
