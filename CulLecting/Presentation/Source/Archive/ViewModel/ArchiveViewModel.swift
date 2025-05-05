//
//  ArchiveViewModel.swift
//  CulLecting
//
//  Created by 김승희 on 4/23/25.
//


import UIKit

import RxCocoa
import RxSwift

final class ArchiveViewModel {
    
    struct Input {
        let fetchTrigger: Observable<Void>
        let segmentChanged: Observable<Int>
    }
    
    struct Output {
        let archivingList: Driver<[Ticket]>
        let preferenceCard: Driver<PreferenceCardEntity?>
        let isShowingArchiving: Driver<Bool>
    }
    
    private let useCase: ArchivingUseCase
    private let disposeBag = DisposeBag()
    
    private let archivingRelay = BehaviorRelay<[Ticket]>(value: [])
    private let preferenceCardRelay = BehaviorRelay<PreferenceCardEntity?>(value: nil)
    private let isArchivingRelay = BehaviorRelay<Bool>(value: true)
    let archivingList = BehaviorRelay<[Ticket]>(value: [])
    let preferenceCard = BehaviorRelay<PreferenceCardEntity?>(value: nil)
    
    
    init(useCase: ArchivingUseCase) {
        self.useCase = useCase
    }
    
    func transform(input: Input) -> Output {
        input.fetchTrigger
            .flatMapLatest { [weak self] in
                self?.useCase.fetchArchiving()
                    .asObservable() ?? .just([])
            }
            .bind(to: archivingRelay)
            .disposed(by: disposeBag)
        
        input.fetchTrigger
            .flatMapLatest { [weak self] in
                self?.useCase.getPreferenceCard()
                    .map(Optional.init)
                    .asObservable()
                    .catchAndReturn(nil) ?? .just(nil)
            }
            .bind(to: preferenceCardRelay)
            .disposed(by: disposeBag)
        
        input.segmentChanged
            .map { $0 == 0 }
            .bind(to: isArchivingRelay)
            .disposed(by: disposeBag)
        
        return Output(
            archivingList: archivingRelay.asDriver(),
            preferenceCard: preferenceCardRelay.asDriver(),
            isShowingArchiving: isArchivingRelay.asDriver()
        )
    }
}
