//
//  LoginViewModel.swift
//  CulLecting
//
//  Created by 김승희 on 3/27/25.
//

import Foundation

protocol LoginViewInput {
    
}

protocol LoginViewOutput {
    
}

protocol LoginViewModel {
    func transform(input: LoginViewInput) -> LoginViewOutput
}

// class LoginVM: LoginViewModel {

// }
