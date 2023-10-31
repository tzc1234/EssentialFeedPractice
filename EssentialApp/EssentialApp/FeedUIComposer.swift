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
    private typealias FeedPresentationAdapter = LoadResourcePresentationAdapter<Paginated<FeedImage>, FeedViewAdapter>
    
    public static func feedComposedWith(
        feedLoader: @escaping () -> AnyPublisher<Paginated<FeedImage>, Error>,
        imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher,
        selection: @escaping (FeedImage) -> Void) -> ListViewController {
            let presentationAdapter = FeedPresentationAdapter(loader: feedLoader)
            let refreshController = RefreshViewController()
            refreshController.onRefresh = presentationAdapter.loadResource
            
            let feedViewController = ListViewController(refreshController: refreshController)
            feedViewController.title = FeedPresenter.title
            feedViewController.registerTableCell(FeedImageCell.self, forCellReuseIdentifier: FeedImageCell.identifier)
            
            presentationAdapter.presenter = LoadResourcePresenter(
                view: FeedViewAdapter(controller: feedViewController, imageLoader: imageLoader, selection: selection),
                loadingView: WeakRefProxy(refreshController),
                errorView: WeakRefProxy(feedViewController),
                mapper: { $0 })
            
            return feedViewController
        }
}
