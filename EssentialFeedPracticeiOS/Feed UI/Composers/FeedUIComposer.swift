//
//  FeedUIComposer.swift
//  EssentialFeedPracticeiOS
//
//  Created by Tsz-Lung on 26/09/2023.
//

import EssentialFeedPractice

public enum FeedUIComposer {
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let presentationAdapter = FeedLoaderPresentationAdapter(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController(delegate: presentationAdapter)
        let feedViewController = FeedViewController(refreshController: refreshController)
        feedViewController.title = FeedPresenter.title
        
        presentationAdapter.presenter = FeedPresenter(
            view: FeedViewAdapter(controller: feedViewController, imageLoader: imageLoader),
            loadingView: WeakRefProxy(refreshController))
        
        return feedViewController
    }
}
