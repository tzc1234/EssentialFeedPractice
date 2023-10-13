//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by Tsz-Lung on 10/10/2023.
//

import UIKit
import EssentialFeedPractice
import EssentialFeedPracticeiOS

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        
        let remoteURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
        let session = URLSession(configuration: .ephemeral)
        let client = URLSessionHTTPClient(session: session)
        let remoteFeedLoader = RemoteFeedLoader(client: client, url: remoteURL)
        let remoteImageLoader = RemoteFeedImageDataLoader(client: client)
        
        let feedViewController = FeedUIComposer.feedComposedWith(
            feedLoader: remoteFeedLoader,
            imageLoader: remoteImageLoader)
        
        window = UIWindow(windowScene: scene)
        window?.rootViewController = UINavigationController(rootViewController: feedViewController)
        window?.makeKeyAndVisible()
    }
}
