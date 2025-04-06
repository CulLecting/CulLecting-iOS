//
//  MyPageAssembly.swift
//  CulLecting
//
//  Created by 김승희 on 4/7/25.
//


import UIKit
import Swinject

public struct MyPageAssembly: Assembly {
    public func assemble(container: Container) {
        container.register(MyPageViewController.self) { _ in
            MyPageViewController()
        }
        // 마이페이지 뷰모델 등 추가 등록 가능
    }
}
