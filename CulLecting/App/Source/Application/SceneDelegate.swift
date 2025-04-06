//
//  SceneDelegate.swift
//  CulLecting
//
//  Created by 김승희 on 3/25/25.
//

import UIKit

import Swinject

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var appCoordinator: DefaultAppCoordinatorProtocol?
    var assembler: Assembler!

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        // Assembler에 전체 AppAssembly에 등록된 전체 DI 구성을 등록
        assembler = Assembler([AppAssembly()])
        // assembler에 등록된 Container를 resolve
        let container = assembler.resolver
        
        let navigationController = UINavigationController()
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        // AppCoordinatorProtocol 타입의 객체를 resolve, 미리 AppAssembly에 등록한 AppCoordinator 구현체를 찾아서 생성
        // navigationController, window를 인자로 전달하여 화면 전환 및 윈도우 관리에 필요한 의존성을 주입받음
        guard let appCoordinator = container.resolve(DefaultAppCoordinatorProtocol.self, arguments: navigationController, window) else {
            fatalError("AppCoordinator를 DI Container에서 주입받지 못함")
        }
        self.appCoordinator = appCoordinator
        // AppCoordinator의 start() 메서드를 호출하여 앱의 초기 플로우를 실행함 (로그인/온보딩/탭바)
        appCoordinator.start()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        
    }

    func sceneWillResignActive(_ scene: UIScene) {
        
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}

