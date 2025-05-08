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
    var currentTickets: [Ticket] {
        return archivingRelay.value
    }
    
    struct Input {
        let fetchTrigger: Observable<Void>
        let segmentChanged: Observable<Int>
        let ticketTapped: Observable<Ticket>
        let imageUploadTrigger: Observable<UIImage>
    }
    
    struct Output {
        let archivingList: Driver<[Ticket]>
        let preferenceCard: Driver<PreferenceCardEntity?>
        let isShowingArchiving: Driver<Bool>
        let ticketCount: Driver<Int>
        let selectedTicket: Signal<Ticket>
        let imageUploadCompleted: Signal<Ticket>
    }
    
    private let useCase: ArchivingUseCase
    private let disposeBag = DisposeBag()
    
    private let archivingRelay = BehaviorRelay<[Ticket]>(value: [])
    private let preferenceCardRelay = BehaviorRelay<PreferenceCardEntity?>(value: nil)
    private let isArchivingRelay = BehaviorRelay<Bool>(value: true)
    
    init(useCase: ArchivingUseCase) {
        self.useCase = useCase
    }
    
    func transform(input: Input) -> Output {
        let ticketCount = archivingRelay
            .map { $0.count }
            .asDriver(onErrorJustReturn: 0)
        
        let selectedTicket = input.ticketTapped
            .asSignal(onErrorSignalWith: .empty())
        
        input.fetchTrigger
            .flatMapLatest { [weak self] in
                self?.useCase.fetchArchiving()
                    .asObservable()
                    .catchAndReturn([]) ?? .just([])
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
        
        let imageUploadCompleted = input.imageUploadTrigger
            .flatMapLatest { image in
                self.useCase.uploadArchiveImg(image: image)
                    .flatMap { self.useCase.fetchTicket(id: $0) }
                    .asObservable()
                    .catch { error in
                        if let netError = error as? NetworkError {
                            print("🔥 NetworkError 발생: \(netError)")
                        } else {
                            print("❗ 알 수 없는 에러 발생: \(error.localizedDescription)")
                        }
                        return .empty()
                    }
            }
            .asSignal(onErrorSignalWith: .empty())

        
        return Output(
            archivingList: archivingRelay.asDriver(),
            preferenceCard: preferenceCardRelay.asDriver(),
            isShowingArchiving: isArchivingRelay.asDriver(),
            ticketCount: ticketCount,
            selectedTicket: selectedTicket,
            imageUploadCompleted: imageUploadCompleted
        )
    }
}
