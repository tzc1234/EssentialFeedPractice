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
    private let loadingView: ResourceLoadingView
    private let errorView: ResourceErrorView
    
    public init(view: FeedView, loadingView: ResourceLoadingView, errorView: ResourceErrorView) {
        self.view = view
        self.loadingView = loadingView
        self.errorView = errorView
    }
    
    public func didStartLoadingFeed() {
        loadingView.display(ResourceLoadingViewModel(isLoading: true))
        errorView.display(.noError)
    }
    
    public func didFinishLoadingFeed(with feed: [FeedImage]) {
        view.display(Self.map(feed))
        loadingView.display(ResourceLoadingViewModel(isLoading: false))
    }
    
    public func didFinishLoadingFeed(with error: Error) {
        errorView.display(.error(message: Self.feedLoadError))
        loadingView.display(ResourceLoadingViewModel(isLoading: false))
    }
    
    public static func map(_ feed: [FeedImage]) -> FeedViewModel {
        FeedViewModel(feed: feed)
    }
}
