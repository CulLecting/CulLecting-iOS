//
//  TicketDetailViewModel.swift
//  CulLecting
//
//  Created by 김승희 on 4/28/25.
//


import UIKit

import RxCocoa
import RxSwift


final class TicketDetailViewModel {

    struct Input {
        let editTrigger: Observable<Void>
    }

    struct Output {
        let editTapped: Observable<Void>
        let ticketUpdated: Observable<Ticket>
    }

    private let disposeBag = DisposeBag()
    private let useCase: ArchivingUseCase

    private let ticketUpdatedRelay = PublishRelay<Ticket>()

    init(useCase: ArchivingUseCase) {
        self.useCase = useCase
    }

    func transform(input: Input) -> Output {
        return Output(
            editTapped: input.editTrigger,
            ticketUpdated: ticketUpdatedRelay.asObservable()
        )
    }
    
    func updateTicket(_ ticket: Ticket) {
        ticketUpdatedRelay.accept(ticket)
    }
}
