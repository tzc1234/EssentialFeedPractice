//
//  LoadResourcePresenter.swift
//  EssentialFeedPractice
//
//  Created by Tsz-Lung on 25/10/2023.
//

import Foundation

public final class LoadResourcePresenter {
    public static var feedLoadError: String {
        NSLocalizedString("FEED_VIEW_CONNECTION_ERROR",
            tableName: tableName,
            bundle: bundle,
            comment: "Feed load error message")
    }
    
    private static let tableName = "Feed"
    private static var bundle: Bundle { Bundle(for: Self.self) }
    
    private let view: FeedView
    private let loadingView: FeedLoadingView
    private let errorView: FeedErrorView
    
    public init(view: FeedView, loadingView: FeedLoadingView, errorView: FeedErrorView) {
        self.view = view
        self.loadingView = loadingView
        self.errorView = errorView
    }
    
    public func didStartLoading() {
        loadingView.display(FeedLoadingViewModel(isLoading: true))
        errorView.display(.noError)
    }
    
    public func didFinishLoadingFeed(with feed: [FeedImage]) {
        view.display(FeedViewModel(feed: feed))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    public func didFinishLoadingFeed(with error: Error) {
        errorView.display(.error(message: Self.feedLoadError))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
}
