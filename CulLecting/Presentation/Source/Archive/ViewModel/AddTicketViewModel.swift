//
//  AddTicketViewModel.swift
//  CulLecting
//
//  Created by 김승희 on 4/23/25.
//


import UIKit

import RxSwift
import RxCocoa


final class AddTicketViewModel {
    
    struct Input {
        let image: Observable<UIImage?>
        let title: Observable<String>
        let description: Observable<String>
        let date: Observable<Date>
        let category: Observable<String>
        let template: Observable<String>
        let uploadTap: Observable<Void>
    }

    struct Output {
        let uploadResult: Signal<Bool>
        let isUploading: Driver<Bool>
    }
    
    private let useCase: ArchivingUseCase
    private let disposeBag = DisposeBag()
    
    private let uploadResultRelay = PublishRelay<Bool>()
    private let isUploadingRelay = BehaviorRelay<Bool>(value: false)
    
    init(useCase: ArchivingUseCase) {
        self.useCase = useCase
    }
    
    func transform(input: Input) -> Output {
        let combinedInput = Observable.combineLatest(
            input.image,
            input.title,
            input.description,
            input.date,
            input.category,
            input.template
        )
        
        input.uploadTap
            .withLatestFrom(combinedInput)
            .flatMapLatest { [weak self] image, title, description, date, category, template -> Observable<Bool> in
                guard let self = self else { return .just(false) }
                guard let image = image else { return .just(false) }

                let dateStr = self.convertDate(date)
                
                self.isUploadingRelay.accept(true)
                return self.useCase.uploadArchiving(
                    image: image,
                    title: title,
                    description: description,
                    date: dateStr,
                    category: category,
                    template: template
                )
                .andThen(Observable.just(true))
                .catchAndReturn(false)
                .do(onNext: { _ in self.isUploadingRelay.accept(false) })
            }
            .bind(to: uploadResultRelay)
            .disposed(by: disposeBag)
        
        return Output(
            uploadResult: uploadResultRelay.asSignal(),
            isUploading: isUploadingRelay.asDriver()
        )
    }

    private func convertDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
