//
//  ArchiveAssembly.swift
//  CulLecting
//
//  Created by 김승희 on 4/7/25.
//


import UIKit
import Swinject

public struct ArchiveAssembly: Assembly {
    public func assemble(container: Container) {
        container.register(ArchiveViewController.self) { _ in
            return ArchiveViewController()
        }
    }
}
