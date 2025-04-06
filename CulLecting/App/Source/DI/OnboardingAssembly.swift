//
//  OnboardingAssembly.swift
//  CulLecting
//
//  Created by 김승희 on 4/7/25.
//


import UIKit
import Swinject

public struct OnboardingAssembly: Assembly {
    public func assemble(container: Container) {
        container.register(OnboardingViewController.self) { _ in
            OnboardingViewController()
        }
        
    }
}
