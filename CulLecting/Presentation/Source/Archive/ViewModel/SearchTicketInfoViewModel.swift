//
//  SearchTicketInfoViewModel.swift
//  CulLecting
//
//  Created by 김승희 on 4/28/25.
//


import UIKit

import RxCocoa
import RxSwift


final class SearchTicketInfoViewModel {
    
    struct Input {
        let searchTrigger: Observable<Void>
        let searchText: Observable<String>
        let selectImage: Observable<UIImage>
    }
    
    struct Output {
        let searchResults: Driver<[Ticket]>
        let isLoading: Driver<Bool>
        let uploadCompleted: Signal<Ticket>
    }
    
    private let disposeBag = DisposeBag()
    
    private let archivingUseCase: ArchivingUseCase
    private let actionType: TicketActionType
    
    private let searchResultRelay = BehaviorRelay<[Ticket]>(value: [])
    private let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    private let uploadCompletedRelay = PublishRelay<Ticket>()
    private let currentSearchTextRelay = BehaviorRelay<String>(value: "")
    
    init(archivingUseCase: ArchivingUseCase, actionType: TicketActionType) {
        self.archivingUseCase = archivingUseCase
        self.actionType = actionType
    }
    
    func transform(input: Input) -> Output {
        
        bindSearch(input: input)
        bindImageSelection(input: input)
        
        return Output(
            searchResults: searchResultRelay.asDriver(),
            isLoading: isLoadingRelay.asDriver(),
            uploadCompleted: uploadCompletedRelay.asSignal()
        )
    }
}

// MARK: - Binding
private extension SearchTicketInfoViewModel {
    
    func bindSearch(input: Input) {
        input.searchText
            .bind(to: currentSearchTextRelay)
            .disposed(by: disposeBag)
        
        input.searchTrigger
            .withLatestFrom(currentSearchTextRelay)
            .flatMapLatest { [weak self] query -> Observable<[Ticket]> in
                guard let self else { return .just([]) }
                self.isLoadingRelay.accept(true)
                
                // TODO: 실제 검색 API 연결 필요
                return Observable.just([]) // 임시
            }
            .subscribe(onNext: { [weak self] tickets in
                self?.searchResultRelay.accept(tickets)
                self?.isLoadingRelay.accept(false)
            })
            .disposed(by: disposeBag)
    }
    
    func bindImageSelection(input: Input) {
        input.selectImage
            .flatMapLatest { [weak self] image -> Observable<Ticket> in
                guard let self else { return .empty() }
                return self.handleImageSelection(image: image).asObservable()
            }
            .subscribe(
                onNext: { [weak self] ticket in
                    self?.uploadCompletedRelay.accept(ticket)
                },
                onError: { error in
                    print("이미지 처리 실패: \(error.localizedDescription)")
                }
            )
            .disposed(by: disposeBag)
    }
    
    func handleImageSelection(image: UIImage) -> Single<Ticket> {
        switch actionType {
        case .create:
            return archivingUseCase.uploadArchiveImg(image: image)
                .flatMap { [weak self] ticketId in
                    guard let self else { return .never() }
                    return self.archivingUseCase.fetchTicket(id: ticketId)
                }
        case .edit(let ticket):
            return archivingUseCase.updateImage(id: ticket.id, image: image)
                .andThen(Single.just(ticket))
        }
    }
}
