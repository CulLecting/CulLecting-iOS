//
//  ArchiveViewModel.swift
//  CulLecting
//
//  Created by 김승희 on 4/23/25.
//


import UIKit

import RxCocoa
import RxSwift


// MARK: - Navigation Events
enum ArchiveNavigationEvent {
    case showTicketDetail(Ticket)
    case showDeleteSuccess
    case showError(String)
}

final class ArchiveViewModel {
    var currentTickets: [Ticket] {
        return archivingRelay.value
    }

    struct Input {
        let fetchTrigger: Observable<Void>
        let segmentChanged: Observable<Int>
        let ticketTapped: Observable<Ticket>
        let imageUploadTrigger: Observable<UIImage>
        let updateTicketImageTrigger: Observable<(ticketId: String, image: UIImage)>
        let deleteTicketTrigger: Observable<Ticket>
    }

    struct Output {
        let archivingList: Driver<[Ticket]>
        let preferenceCard: Driver<PreferenceCardEntity?>
        let isShowingArchiving: Driver<Bool>
        let ticketCount: Driver<Int>
        let selectedTicket: Signal<Ticket>
        let imageUploadCompleted: Signal<Ticket>
        let navigationEvent: Signal<ArchiveNavigationEvent>
        let isLoggedIn: Driver<Bool>
    }

    private let useCase: ArchivingUseCase
    private let authUseCase: AuthUseCaseProtocol
    private let disposeBag = DisposeBag()

    private let archivingRelay = BehaviorRelay<[Ticket]>(value: [])
    private let preferenceCardRelay = BehaviorRelay<PreferenceCardEntity?>(value: nil)
    private let isArchivingRelay = BehaviorRelay<Bool>(value: true)
    private let navigationEventRelay = PublishRelay<ArchiveNavigationEvent>()

    init(useCase: ArchivingUseCase, authUseCase: AuthUseCaseProtocol) {
        self.useCase = useCase
        self.authUseCase = authUseCase
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
                    .catch { error -> Observable<[Ticket]> in
                        print("티켓 로딩 실패: \(error) - 더미 데이터 사용")
                        return .just(Ticket.mockTickets)
                    } ?? .just(Ticket.mockTickets)
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
                            print("NetworkError 발생: \(netError)")
                        } else {
                            print("알 수 없는 에러 발생: \(error.localizedDescription)")
                        }
                        return .empty()
                    }
            }
            .asSignal(onErrorSignalWith: .empty())

        input.updateTicketImageTrigger
            .flatMapLatest { [weak self] (ticketId, newImage) -> Observable<Ticket> in
                guard let self = self else { return .empty() }
                return self.useCase.updateImage(id: ticketId, image: newImage)
                    .andThen(self.useCase.fetchTicket(id: ticketId))
                    .asObservable()
                    .catch { error in
                        self.navigationEventRelay.accept(.showError("티켓 업데이트 실패: \(error.localizedDescription)"))
                        return .empty()
                    }
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] updatedTicket in
                self?.navigationEventRelay.accept(.showTicketDetail(updatedTicket))
            })
            .disposed(by: disposeBag)

        input.deleteTicketTrigger
            .flatMapLatest { [weak self] ticket -> Observable<Void> in
                guard let self = self else {
                    return Observable.just(())
                }

                return self.useCase.deleteArchiving(id: ticket.id)
                    .andThen(Observable.just(()))
                    .catch { error in
                        self.navigationEventRelay.accept(
                            .showError("티켓 삭제 실패: \(error.localizedDescription)")
                        )
                        return Observable.just(())
                    }
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.navigationEventRelay.accept(.showDeleteSuccess)
            })
            .disposed(by: disposeBag)

        let isLoggedIn = input.fetchTrigger
            .map { [weak self] _ in
                self?.authUseCase.isLoggedIn ?? false
            }
            .asDriver(onErrorJustReturn: false)

        return Output(
            archivingList: archivingRelay.asDriver(),
            preferenceCard: preferenceCardRelay.asDriver(),
            isShowingArchiving: isArchivingRelay.asDriver(),
            ticketCount: ticketCount,
            selectedTicket: selectedTicket,
            imageUploadCompleted: imageUploadCompleted,
            navigationEvent: navigationEventRelay.asSignal(),
            isLoggedIn: isLoggedIn
        )
    }
}
