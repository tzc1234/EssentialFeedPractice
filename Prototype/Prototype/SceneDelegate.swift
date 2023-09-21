//
//  SceneDelegate.swift
//  Prototype
//
//  Created by Tsz-Lung on 20/09/2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: scene)
        let nav = UINavigationController(rootViewController: FeedViewController())
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
    }
}
