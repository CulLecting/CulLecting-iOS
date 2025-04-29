//
//  MyPageViewModel.swift
//  CulLecting
//
//  Created by 김승희 on 4/13/25.
//


import UIKit

import RxSwift
import RxCocoa


final class MypageViewModel {
    
    struct Input {
        
    }

    struct Output {
        
    }
    
    private let useCase: MypageUseCase
    private let disposeBag = DisposeBag()
    
    
    init(useCase: MypageUseCase) {
        self.useCase = useCase
    }
    
//    func transform(input: Input) -> Output {
//
//    }
}
