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
    
    struct Input {
        
    }

    struct Output {
        
    }
    
    private let useCase: HomeUseCase
    private let disposeBag = DisposeBag()
    
    
    init(useCase: HomeUseCase) {
        self.useCase = useCase
    }
    
//    func transform(input: Input) -> Output {
//        
//    }
}
