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

protocol OnboardingViewModelType {
    func transform(input: OnboardingViewModel.Input) -> OnboardingViewModel.Output
}

final class OnboardingViewModel: OnboardingViewModelType {
    private let disposeBag = DisposeBag()
    
    //MARK: Struct Input Output
    struct Input {
        let nextTrigger: Observable<Void>
        let backTrigger: Observable<Void>
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
    private let currentStepRelay = BehaviorRelay<OnboardingStep>(value: .location)
    private let selectedCategories = BehaviorRelay<Set<String>>(value: [])
    private let selectedLocations = BehaviorRelay<Set<String>>(value: [])
    private let finishSubject = PublishSubject<Bool>()
    private let progressRelay = BehaviorRelay<Float>(value: 0.5)
    
    
    //MARK: transform
    func transform(input: Input) -> Output {
        input.nextTrigger
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                print("nextTrigger 발생, selectedLocations: \(self.selectedLocations.value), selectedCategories: \(self.selectedCategories.value)")
                switch self.currentStepRelay.value {
                case .location:
                    if self.selectedLocations.value.count >= 1 {
                        self.currentStepRelay.accept(.category)
                        self.progressRelay.accept(1.0)
                    }
                case .category:
                    if self.selectedCategories.value.count >= 1 {
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
        
        input.tapLocation
            .withLatestFrom(selectedLocations) { tapped, current in
                var new = current
                print("tapped: \(tapped), new.count: \(new.count)")
                if new.contains(tapped) {
                    new.remove(tapped)
                } else if new.count < 3 {
                    new.insert(tapped)
                }
                return new
            }
            .bind(to: selectedLocations)
            .disposed(by: disposeBag)
        
        input.tapCategory
            .withLatestFrom(selectedCategories) { tapped, current in
                var new = current
                if new.contains(tapped) {
                    new.remove(tapped)
                } else if new.count < 3 {
                    new.insert(tapped)
                }
                return new
            }
            .bind(to: selectedCategories)
            .disposed(by: disposeBag)
        
        let enableNext = currentStepRelay.asObservable().flatMapLatest { step -> Observable<Bool> in
            switch step {
            case .location:
                return self.selectedLocations.asObservable().map { $0.count >= 1 }
            case .category:
                return self.selectedCategories.asObservable().map { $0.count >= 1 }
            }
        }
        
        let labelText = currentStepRelay.asObservable().map { step in
            switch step {
            case .location:
                return "어떤 종류의 문화 콘텐츠를 좋아하세요?"
            case .category:
                return "주로 어디에서 문화 콘텐츠를 즐기세요?"
            }
        }
        
        return Output(
            currentStep: currentStepRelay.asObservable(),
            selectedCategories: selectedCategories.asObservable(),
            selectedLocations: selectedLocations.asObservable(),
            enableNext: enableNext,
            finish: finishSubject.asObservable(),
            labelText: labelText,
            progress: progressRelay.asObservable()
        )
    }
}
