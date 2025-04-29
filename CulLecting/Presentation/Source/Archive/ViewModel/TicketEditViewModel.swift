//
//  TicketEditViewModel.swift
//  CulLecting
//
//  Created by 김승희 on 4/28/25.
//


import UIKit

import RxCocoa
import RxSwift


final class TicketEditViewModel {
    
    struct Input {
        let titleInput: Observable<String>
        let descriptionInput: Observable<String>
        let dateInput: Observable<String>
        let categoryInput: Observable<String>
        let saveTrigger: Observable<Void>
    }
    
    struct Output {
        let saveCompleted: Driver<Void>
        let saveFailed: Driver<Error>
        let enableSave: Driver<Bool>
    }
    
    private let useCase: ArchivingUseCase
    private let disposeBag = DisposeBag()
    
    private let titleRelay = BehaviorRelay<String>(value: "")
    private let descriptionRelay = BehaviorRelay<String>(value: "")
    private let dateRelay = BehaviorRelay<String>(value: "")
    private let categoryRelay = BehaviorRelay<String>(value: "")
    
    private let saveCompletedRelay = PublishRelay<Void>()
    private let saveFailedRelay = PublishRelay<Error>()
    private let enableSaveRelay = BehaviorRelay<Bool>(value: false)
    
    private let ticketId: String
    
    init(useCase: ArchivingUseCase, ticketId: String) {
        self.useCase = useCase
        self.ticketId = ticketId
    }
    
    func transform(input: Input) -> Output {
        
        input.titleInput
            .bind(to: titleRelay)
            .disposed(by: disposeBag)
        
        input.descriptionInput
            .bind(to: descriptionRelay)
            .disposed(by: disposeBag)
        
        input.dateInput
            .bind(to: dateRelay)
            .disposed(by: disposeBag)
        
        input.categoryInput
            .bind(to: categoryRelay)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(
            titleRelay,
            descriptionRelay,
            dateRelay,
            categoryRelay
        )
        .map { title, description, date, category in
            !title.isEmpty && !description.isEmpty && !date.isEmpty && !category.isEmpty
        }
        .bind(to: enableSaveRelay)
        .disposed(by: disposeBag)
        
        input.saveTrigger
            .withLatestFrom(
                Observable.combineLatest(titleRelay, descriptionRelay, dateRelay, categoryRelay)
            )
            .flatMapLatest { [weak self] title, description, date, category -> Completable in
                guard let self else { return .error(NSError(domain: "selfDeallocated", code: -1)) }
                return self.useCase.updateArchiving(
                    id: self.ticketId,
                    title: title,
                    description: description,
                    date: date,
                    category: category
                )
            }
            .subscribe(
                onError: { [weak self] error in
                    self?.saveFailedRelay.accept(error)
                },
                onCompleted: { [weak self] in
                    self?.saveCompletedRelay.accept(())
                }             
            )
            .disposed(by: disposeBag)
        
        return Output(
            saveCompleted: saveCompletedRelay.asDriver(onErrorDriveWith: .empty()),
            saveFailed: saveFailedRelay.asDriver(onErrorDriveWith: .empty()),
            enableSave: enableSaveRelay.asDriver()
        )
    }
}
