//
//  SearchTicketInfoViewModel.swift
//  CulLecting
//
//  Created by 김승희 on 4/28/25.
//


import UIKit

import RxCocoa
import RxSwift


final class SearchCulturalInfoViewModel {
    struct Input {
        let searchTextTrigger: Observable<String>  // 검색어
        let selectImage: Observable<UIImage>
    }
    
    struct Output {
        let searchResults: Driver<[CulturalImageEntity]>
        let isLoading: Driver<Bool>
        let uploadCompleted: Signal<Ticket>
    }
    
    private let culturalRepository: CulturalRepositoryProtocol
    private let archivingUseCase: ArchivingUseCase
    private let actionType: TicketActionType
    private let disposeBag = DisposeBag()
    
    private let searchResultsRelay = BehaviorRelay<[CulturalImageEntity]>(value: [])
    private let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    private let uploadCompletedRelay = PublishRelay<Ticket>()
    
    init(
        culturalRepository: CulturalRepositoryProtocol,
        archivingUseCase: ArchivingUseCase,
        actionType: TicketActionType
    ) {
        self.culturalRepository = culturalRepository
        self.archivingUseCase = archivingUseCase
        self.actionType = actionType
    }
    
    func transform(input: Input) -> Output {
        
        input.searchTextTrigger
            .do(onNext: { [weak self] _ in self?.isLoadingRelay.accept(true) })
            .flatMapLatest { [weak self] keyword -> Observable<[CulturalImageEntity]> in
                guard let self else { return .just([]) }
                return self.culturalRepository.findCulturalImage(keyword: keyword)
                    .asObservable()
                    .catchAndReturn([])
            }
            .subscribe(onNext: { [weak self] images in
                self?.searchResultsRelay.accept(images)
                self?.isLoadingRelay.accept(false)
            })
            .disposed(by: disposeBag)
        
        input.selectImage
            .flatMapLatest { [weak self] image -> Observable<Ticket> in
                guard let self else { return .empty() }
                return self.handleImageSelection(image: image).asObservable()
            }
            .bind(to: uploadCompletedRelay)
            .disposed(by: disposeBag)
        
        return Output(
            searchResults: searchResultsRelay.asDriver(),
            isLoading: isLoadingRelay.asDriver(),
            uploadCompleted: uploadCompletedRelay.asSignal()
        )
    }
    
    private func handleImageSelection(image: UIImage) -> Single<Ticket> {
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
