//
//  HomeViewModel.swift
//  CulLecting
//
//  Created by 김승희 on 4/27/25.
//


import UIKit

import RxSwift
import RxCocoa


final class HomeViewModel {
    
    // MARK: Input & Output
    struct Input {
        let viewWillAppearTrigger: Observable<Void>
        let selectedDate: Observable<Date>
    }
    
    struct Output {
        let myTickets: Driver<[Ticket]>
        let recommendCulturals: Driver<[CulturalContentEntity]>
        let latestCulturals: Driver<[String: [CulturalContentEntity]]>
        let todayCulturals: Driver<[CulturalContentEntity]>
    }
    
    // MARK: Properties
    private let useCase: HomeUseCaseProtocol
    private let disposeBag = DisposeBag()
    
    private let myTicketsRelay = BehaviorRelay<[Ticket]>(value: [])
    private let recommendCulturalsRelay = BehaviorRelay<[CulturalContentEntity]>(value: [])
    private let latestCulturalsRelay = BehaviorRelay<[String: [CulturalContentEntity]]>(value: [:])
    
    private let todayCulturalsRelay = BehaviorRelay<[CulturalContentEntity]>(value: [])
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    // MARK: init
    init(useCase: HomeUseCaseProtocol) {
        self.useCase = useCase
    }
    
    // MARK: Transform
    func transform(input: Input) -> Output {
        input.viewWillAppearTrigger
            .subscribe(onNext: { [weak self] in
                self?.fetchArchiving()
                self?.fetchRecommendCulturals()
                self?.fetchLatestCulturals()
                self?.updateSelectedDate(Date())
            })
            .disposed(by: disposeBag)
        
        input.selectedDate
            .flatMapLatest { [weak self] date -> Observable<[CulturalContentEntity]> in
                guard let self else { return .empty() }
                return self.useCase.findCultural(from: date)
                    .asObservable()
                    .catch { error in
                        print("📆 날짜별 문화콘텐츠 로딩 실패: \(error) - 더미 데이터 사용")
                        return .just(CulturalContentEntity.todayEvents)
                    }
            }
            .bind(to: todayCulturalsRelay)
            .disposed(by: disposeBag)
        
        return Output(
            myTickets: myTicketsRelay.asDriver(),
            recommendCulturals: recommendCulturalsRelay.asDriver(),
            latestCulturals: latestCulturalsRelay.asDriver(),
            todayCulturals: todayCulturalsRelay.asDriver()
        )
    }
    
    // MARK: Fetch Methods
    private func fetchArchiving() {
        useCase.fetchArchiving()
            .catch { error -> Single<[Ticket]> in
                print("⚠️ 아카이빙 티켓 로딩 실패: \(error) - 더미 데이터 사용")
                return .just(Ticket.mockTickets)
            }
            .subscribe(onSuccess: { [weak self] tickets in
                self?.myTicketsRelay.accept(tickets)
            })
            .disposed(by: disposeBag)
    }

    private func fetchRecommendCulturals() {
        useCase.fetchRecommendCultural()
            .catch { error -> Single<[CulturalContentEntity]> in
                print("⚠️ 추천 콘텐츠 로딩 실패: \(error) - 더미 데이터 사용")
                return .just(CulturalContentEntity.recommendedContents)
            }
            .subscribe(onSuccess: { [weak self] contents in
                self?.recommendCulturalsRelay.accept(contents)
            })
            .disposed(by: disposeBag)
    }

    private func fetchLatestCulturals() {
        useCase.fetchLatestCultural()
            .catch { error -> Single<[String: [CulturalContentEntity]]> in
                print("⚠️ 최근 콘텐츠 로딩 실패: \(error) - 더미 데이터 사용")
                return .just(CulturalContentEntity.latestContents)
            }
            .subscribe(onSuccess: { [weak self] contents in
                self?.latestCulturalsRelay.accept(contents)
            })
            .disposed(by: disposeBag)
    }

    func updateSelectedDate(_ date: Date) {
        useCase.findCultural(from: date)
            .catch { error -> Single<[CulturalContentEntity]> in
                print("⚠️ 날짜별 문화콘텐츠 로딩 실패: \(error) - 더미 데이터 사용")
                return .just(CulturalContentEntity.todayEvents)
            }
            .subscribe(onSuccess: { [weak self] contents in
                self?.todayCulturalsRelay.accept(contents)
            })
            .disposed(by: disposeBag)
    }

}
