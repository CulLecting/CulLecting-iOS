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
        let updatedTicket: Driver<Ticket>
        let saveFailed: Driver<Error>
    }

    private let useCase: ArchivingUseCase
    private let originalTicket: Ticket
    private let disposeBag = DisposeBag()

    private let titleRelay = BehaviorRelay<String>(value: "")
    private let descriptionRelay = BehaviorRelay<String>(value: "")
    private let dateRelay = BehaviorRelay<String>(value: "")
    private let categoryRelay = BehaviorRelay<String>(value: "")

    private let updatedTicketRelay = PublishRelay<Ticket>()
    private let saveFailedRelay = PublishRelay<Error>()

    init(useCase: ArchivingUseCase, ticket: Ticket) {
        self.useCase = useCase
        self.originalTicket = ticket
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

        input.saveTrigger
            .withLatestFrom(Observable.combineLatest(titleRelay, descriptionRelay, dateRelay, categoryRelay))
            .flatMapLatest { [weak self] title, description, date, category -> Completable in
                guard let self else {
                    return .error(NSError(domain: "selfDeallocated", code: -1))
                }

                return self.useCase.updateArchiving(
                    id: self.originalTicket.id,
                    title: title,
                    description: description,
                    date: date,
                    category: category
                )
                .andThen(Completable.create { completable in
                    let updated = self.originalTicket.updated(
                        title: title,
                        description: description,
                        date: date,
                        category: category
                    )
                    self.updatedTicketRelay.accept(updated)
                    completable(.completed)
                    return Disposables.create()
                })
            }
            .subscribe(onError: { [weak self] error in
                self?.saveFailedRelay.accept(error)
            })
            .disposed(by: disposeBag)

        return Output(
            updatedTicket: updatedTicketRelay.asDriver(onErrorDriveWith: .empty()),
            saveFailed: saveFailedRelay.asDriver(onErrorDriveWith: .empty())
        )
    }
}
