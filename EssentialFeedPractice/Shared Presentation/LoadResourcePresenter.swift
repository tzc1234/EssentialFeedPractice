//
//  LoadResourcePresenter.swift
//  EssentialFeedPractice
//
//  Created by Tsz-Lung on 25/10/2023.
//

import Foundation

public protocol ResourceView {
    func display(_ viewModel: String)
}

public final class LoadResourcePresenter {
    public typealias Mapper = (String) -> String
    
    public static var feedLoadError: String {
        NSLocalizedString("FEED_VIEW_CONNECTION_ERROR",
            tableName: tableName,
            bundle: bundle,
            comment: "Feed load error message")
    }
    
    private static let tableName = "Feed"
    private static var bundle: Bundle { Bundle(for: Self.self) }
    
    private let view: ResourceView
    private let loadingView: FeedLoadingView
    private let errorView: FeedErrorView
    private let mapper: Mapper
    
    public init(view: ResourceView, loadingView: FeedLoadingView, errorView: FeedErrorView, mapper: @escaping Mapper) {
        self.view = view
        self.loadingView = loadingView
        self.errorView = errorView
        self.mapper = mapper
    }
    
    public func didStartLoading() {
        loadingView.display(FeedLoadingViewModel(isLoading: true))
        errorView.display(.noError)
    }
    
    public func didFinishLoading(with resource: String) {
        view.display(mapper(resource))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    public func didFinishLoadingFeed(with error: Error) {
        errorView.display(.error(message: Self.feedLoadError))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
}
