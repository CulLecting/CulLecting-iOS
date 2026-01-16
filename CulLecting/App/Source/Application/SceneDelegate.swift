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
    var appCoordinator: FirstCoordinator?
    var appDIContainer: AppDIContainer?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        self.window = window

        let tap = UITapGestureRecognizer(target: window, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        window.addGestureRecognizer(tap)

        // Setup DI
        let assembler = Assembler([AppAssembly()])
        let container = assembler.resolver as! Container
        let appDIContainer = AppDIContainer(container: container)
        self.appDIContainer = appDIContainer

        // Setup Root
        let navigationController = UINavigationController()
        window.rootViewController = navigationController

        let appCoordinator = appDIContainer.makeFirstCoordinator(navigationController: navigationController)
        self.appCoordinator = appCoordinator
        appCoordinator.start()

        window.makeKeyAndVisible()
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

