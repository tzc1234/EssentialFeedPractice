//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by Tsz-Lung on 10/10/2023.
//

import UIKit
import Combine
import CoreData
import EssentialFeedPractice
import EssentialFeedPracticeiOS

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private lazy var localFeedLoader: LocalFeedLoader = {
        LocalFeedLoader(store: store)
    }()
    private lazy var localImageLoader: LocalFeedImageDataLoader = {
        LocalFeedImageDataLoader(store: store)
    }()
    
    private lazy var baseURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed")!
    
    private lazy var navigationController: UINavigationController = {
        UINavigationController(rootViewController: FeedUIComposer.feedComposedWith(
            feedLoader: makeRemoteFeedLoaderWithLocalFallback,
            imageLoader: makeLocalImageLoaderWithRemoteFallback,
            selection: showComments))
    }()
    
    private lazy var httpClient: HTTPClient = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    private lazy var store: FeedStore & FeedImageDataStore = {
        try! CoreDataFeedStore(
            storeURL: NSPersistentContainer
                .defaultDirectoryURL()
                .appending(component: "feed-store.sqlite"))
    }()
    
    convenience init(httpClient: HTTPClient, store: FeedStore & FeedImageDataStore) {
        self.init()
        self.httpClient = httpClient
        self.store = store
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: scene)
        configureWindow()
    }
    
    func configureWindow() {
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        localFeedLoader.validateCache { _ in }
    }
    
    private func showComments(for image: FeedImage) {
        let url = ImageCommentsEndpoint.get(image.id).url(baseURL: baseURL)
        let comments = CommentsUIComposer.commentsComposedWith(commentsLoader: makeRemoteCommentsLoader(for: url))
        navigationController.pushViewController(comments, animated: true)
    }
    
    private func makeRemoteCommentsLoader(for url: URL) -> () -> AnyPublisher<[ImageComment], Error> {
        return { [httpClient] in
            httpClient
                .getPublisher(url: url)
                .tryMap(ImageCommentsMapper.map)
                .eraseToAnyPublisher()
        }
    }
    
    private func makeRemoteFeedLoaderWithLocalFallback() -> AnyPublisher<Paginated<FeedImage>, Error> {
        let remoteURL = FeedEndpoint.get().url(baseURL: baseURL)
        return httpClient
            .getPublisher(url: remoteURL)
            .tryMap(FeedItemsMapper.map)
            .caching(to: localFeedLoader)
            .fallback(to: localFeedLoader.loadPublisher)
            .map { items in
                Paginated(
                    items: items, 
                    loadMorePublisher: self.makeRemoteLoadMoreLoader(items: items, last: items.last))
            }
            .eraseToAnyPublisher()
    }
    
    private func makeRemoteLoadMoreLoader(items: [FeedImage], 
                                          last: FeedImage?) -> (() -> AnyPublisher<Paginated<FeedImage>, Error>)? {
        last.map { lastItem in
            let url = FeedEndpoint.get(after: lastItem).url(baseURL: baseURL)
            return { [httpClient, localFeedLoader] in
                httpClient
                    .getPublisher(url: url)
                    .tryMap(FeedItemsMapper.map)
                    .map { newItems in
                        let allItems = items + newItems
                        return Paginated(
                            items: allItems,
                            loadMorePublisher: self.makeRemoteLoadMoreLoader(items: allItems, last: newItems.last))
                    }
                    .caching(to: localFeedLoader)
            }
        }
    }
    
    private func makeLocalImageLoaderWithRemoteFallback(url: URL) -> FeedImageDataLoader.Publisher {
        localImageLoader
            .loadImageDataPublisher(from: url)
            .fallback(to: { [httpClient, localImageLoader] in
                httpClient
                    .getPublisher(url: url)
                    .tryMap(FeedImageDataMapper.map)
                    .caching(to: localImageLoader, using: url)
            })
    }
}
