//
//  OnboardingViewModel.swift
//  CulLecting
//
//  Created by 김승희 on 4/12/25.
//


import Foundation

import RxSwift
import RxCocoa


enum OnboardingStep {
    case location
    case category
}

protocol OnboardingViewModelProtocol {
    func transform(input: OnboardingViewModel.Input) -> OnboardingViewModel.Output
}

final class OnboardingViewModel: OnboardingViewModelProtocol {
    
    //MARK: Input Output
    struct Input {
        let nextTrigger: Observable<Void>
        let backTrigger: Observable<Void>
        let skipTrigger: Observable<Void>
        let tapCategory: Observable<String>
        let tapLocation: Observable<String>
    }
    
    struct Output {
        let currentStep: Observable<OnboardingStep>
        let selectedCategories: Observable<Set<String>>
        let selectedLocations: Observable<Set<String>>
        let enableNext: Observable<Bool>
        let finish: Observable<Bool>
        let labelText: Observable<String>
        let progress: Observable<Float>
    }
    
    //MARK: 선언
    private let disposeBag = DisposeBag()
    private let currentStepRelay = BehaviorRelay<OnboardingStep>(value: .location)
    private let selectedCategoriesRelay = BehaviorRelay<Set<String>>(value: [])
    private let selectedLocationsRelay = BehaviorRelay<Set<String>>(value: [])
    private let finishSubject = PublishSubject<Bool>()
    private let progressRelay = BehaviorRelay<Float>(value: 0.5)
    
    //MARK: init
    private let useCase: OnboardingUseCaseProtocol
    
    init(useCase: OnboardingUseCaseProtocol) {
        self.useCase = useCase
    }
    
    //MARK: transform
    func transform(input: Input) -> Output {
        input.nextTrigger
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                print("nextTrigger 발생, selectedLocations: \(self.selectedLocationsRelay.value), selectedCategories: \(self.selectedCategoriesRelay.value)")
                switch self.currentStepRelay.value {
                case .location:
                    if self.selectedLocationsRelay.value.count >= 1 {
                        self.currentStepRelay.accept(.category)
                        self.progressRelay.accept(1.0)
                    }
                case .category:
                    if self.selectedCategoriesRelay.value.count >= 1 {
                        self.finishSubject.onNext(true)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        input.backTrigger
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                if self.currentStepRelay.value == .category {
                    self.currentStepRelay.accept(.location)
                    self.progressRelay.accept(0.5)
                }
            })
            .disposed(by: disposeBag)
        
        input.skipTrigger
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
                self.finishSubject.onNext(true)
            })
            .disposed(by: disposeBag)
        
        input.tapLocation
            .withLatestFrom(selectedLocationsRelay) { tapped, current in
                var new = current
                print("tapped: \(tapped), new.count: \(new.count)")
                if new.contains(tapped) {
                    new.remove(tapped)
                } else if new.count < 3 {
                    new.insert(tapped)
                }
                return new
            }
            .bind(to: selectedLocationsRelay)
            .disposed(by: disposeBag)
        
        input.tapCategory
            .withLatestFrom(selectedCategoriesRelay) { tapped, current in
                var new = current
                if new.contains(tapped) {
                    new.remove(tapped)
                } else if new.count < 3 {
                    new.insert(tapped)
                }
                return new
            }
            .bind(to: selectedCategoriesRelay)
            .disposed(by: disposeBag)
        
        let enableNext = currentStepRelay.asObservable().flatMapLatest { step -> Observable<Bool> in
            switch step {
            case .location:
                return self.selectedLocationsRelay.asObservable().map { $0.count >= 1 }
            case .category:
                return self.selectedCategoriesRelay.asObservable().map { $0.count >= 1 }
            }
        }
        
        let labelText = currentStepRelay.asObservable().map { step in
            switch step {
            case .location:
                return "주로 어디에서 문화 콘텐츠를 즐기세요?"
            case .category:
                return "어떤 종류의 문화 콘텐츠를 좋아하세요?"
            }
        }
        
        return Output(
            currentStep: currentStepRelay.asObservable(),
            selectedCategories: selectedCategoriesRelay.asObservable(),
            selectedLocations: selectedLocationsRelay.asObservable(),
            enableNext: enableNext,
            finish: finishSubject.asObservable(),
            labelText: labelText,
            progress: progressRelay.asObservable()
        )
    }
    
    //MARK: 기타 메서드
    func sendOnboardingData() {
        print("sendOnboardingData() called")
        let locations = Array(selectedLocationsRelay.value)
        let categories = Array(selectedCategoriesRelay.value)
        
        useCase.updateOnboarding(location: locations, category: categories)
            .subscribe(onCompleted: {
                print("온보딩 데이터 서버 전송 완료")
                UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
                self.finishSubject.onNext(true)
            }, onError: { error in
                print("온보딩 데이터 전송 실패: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
    }
}
