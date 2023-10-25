//
//  FeedPresenter.swift
//  EssentialFeedPractice
//
//  Created by Tsz-Lung on 04/10/2023.
//

import Foundation

public protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

public protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

public protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}

public final class FeedPresenter {
    public static var title: String {
        NSLocalizedString("FEED_VIEW_TITLE",
            tableName: "Feed",
            bundle: bundle,
            comment: "Title for the feed view")
    }
    
    public static var feedLoadError: String {
        NSLocalizedString("GENERIC_CONNECTION_ERROR",
            tableName: "Shared",
            bundle: bundle,
            comment: "Feed load error message")
    }
    
    private static var bundle: Bundle {
        Bundle(for: Self.self)
    }
    
    private let view: FeedView
    private let loadingView: FeedLoadingView
    private let errorView: FeedErrorView
    
    public init(view: FeedView, loadingView: FeedLoadingView, errorView: FeedErrorView) {
        self.view = view
        self.loadingView = loadingView
        self.errorView = errorView
    }
    
    public func didStartLoadingFeed() {
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
