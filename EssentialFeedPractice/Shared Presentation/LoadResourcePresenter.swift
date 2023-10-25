//
//  LoadResourcePresenter.swift
//  EssentialFeedPractice
//
//  Created by Tsz-Lung on 25/10/2023.
//

import Foundation

public protocol ResourceView {
    associatedtype ResourceViewModel
    
    func display(_ viewModel: ResourceViewModel)
}

public final class LoadResourcePresenter<Resource, View: ResourceView> {
    public typealias Mapper = (Resource) -> View.ResourceViewModel
    
    public static var feedLoadError: String {
        NSLocalizedString("GENERIC_CONNECTION_ERROR",
            tableName: "Feed",
            bundle: Bundle(for: Self.self),
            comment: "Feed load error message")
    }
    
    private let view: View
    private let loadingView: FeedLoadingView
    private let errorView: FeedErrorView
    private let mapper: Mapper
    
    public init(view: View, loadingView: FeedLoadingView, errorView: FeedErrorView, mapper: @escaping Mapper) {
        self.view = view
        self.loadingView = loadingView
        self.errorView = errorView
        self.mapper = mapper
    }
    
    public func didStartLoading() {
        loadingView.display(FeedLoadingViewModel(isLoading: true))
        errorView.display(.noError)
    }
    
    public func didFinishLoading(with resource: Resource) {
        view.display(mapper(resource))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    public func didFinishLoading(with error: Error) {
        errorView.display(.error(message: Self.feedLoadError))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
}
