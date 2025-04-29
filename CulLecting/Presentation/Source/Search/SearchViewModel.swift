//
//  SearchViewModel.swift
//  CulLecting
//
//  Created by 김승희 on 4/27/25.
//


import UIKit

import RxSwift
import RxCocoa


final class SearchViewModel {
    
    struct Input {
        
    }

    struct Output {
        
    }
    
    private let useCase: SearchUseCase
    private let disposeBag = DisposeBag()
    
    
    init(useCase: SearchUseCase) {
        self.useCase = useCase
    }
    
//    func transform(input: Input) -> Output {
//
//    }
}
