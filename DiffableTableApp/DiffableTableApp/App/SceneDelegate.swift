//
//  SceneDelegate.swift
//  DiffableTableApp
//
//  Created by Данил Чапаров on 23.02.2024.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: scene)
        let mainTabBarViewController = MainTabBarViewController()
        window.rootViewController = mainTabBarViewController
        window.makeKeyAndVisible()
        let router = BaseRouter()
        router.viewController = mainTabBarViewController
        router.startApp()
        self.window = window
    }
}

