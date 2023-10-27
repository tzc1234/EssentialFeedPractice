//
//  FeedUIComposer.swift
//  EssentialFeedPracticeiOS
//
//  Created by Tsz-Lung on 26/09/2023.
//

import Combine
import Foundation
import EssentialFeedPractice
import EssentialFeedPracticeiOS

public enum FeedUIComposer {
    private typealias FeedPresentationAdapter = LoadResourcePresentationAdapter<[FeedImage], FeedViewAdapter>
    
    public static func feedComposedWith(
        feedLoader: @escaping () -> AnyPublisher<[FeedImage], Error>,
        imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) -> ListViewController {
            let presentationAdapter = FeedPresentationAdapter(loader: feedLoader)
            let refreshController = RefreshViewController()
            refreshController.onRefresh = presentationAdapter.loadResource
            
            let feedViewController = ListViewController(refreshController: refreshController)
            feedViewController.title = FeedPresenter.title
            feedViewController.registerTableCell(FeedImageCell.self, forCellReuseIdentifier: FeedImageCell.identifier)
            
            presentationAdapter.presenter = LoadResourcePresenter<[FeedImage], FeedViewAdapter>(
                view: FeedViewAdapter(controller: feedViewController, imageLoader: imageLoader),
                loadingView: WeakRefProxy(refreshController),
                errorView: WeakRefProxy(feedViewController),
                mapper: FeedPresenter.map)
            
            return feedViewController
        }
}
