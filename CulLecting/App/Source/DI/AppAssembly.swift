//
//  AppAssembly.swift
//  CulLecting
//
//  Created by 김승희 on 4/7/25.
//

import Swinject

public struct AppAssembly: Assembly {

    public func assemble(container: Container) {
        LoginAssembly().assemble(container: container)
        OnboardingAssembly().assemble(container: container)
        HomeAssembly().assemble(container: container)
        ArchiveAssembly().assemble(container: container)
        SearchAssembly().assemble(container: container)
        MypageAssembly().assemble(container: container)
    }
}
