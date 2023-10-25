//
//  FeedImagePresenter.swift
//  EssentialFeedPractice
//
//  Created by Tsz-Lung on 04/10/2023.
//

import Foundation

public protocol FeedImageView {
    associatedtype Image
    
    func display(_ viewModel: FeedImageViewModel<Image>)
}

public protocol FeedImageLoadingView {
    func display(_ viewModel: FeedImageLoadingViewModel)
}

public final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    private let view: View
    private let loadingView: FeedImageLoadingView
    private let imageTransformer: (Data) -> Image?
    
    public init(view: View, loadingView: FeedImageLoadingView, imageTransformer: @escaping (Data) -> Image?) {
        self.view = view
        self.loadingView = loadingView
        self.imageTransformer = imageTransformer
    }
    
    public func didStartLoadingImageData(for model: FeedImage) {
        loadingView.display(FeedImageLoadingViewModel(isLoading: true))
        view.display(FeedImageViewModel<Image>(
            description: model.description,
            location: model.location,
            image: nil,
            shouldRetry: false))
    }
    
    public func didFinishLoadingImageData(with data: Data, for model: FeedImage) {
        let image = imageTransformer(data)
        view.display(FeedImageViewModel<Image>(
            description: model.description,
            location: model.location,
            image: image,
            shouldRetry: image == nil))
        loadingView.display(FeedImageLoadingViewModel(isLoading: false))
    }
    
    public func didFinishLoadingImageData(with error: Error, for model: FeedImage) {
        view.display(FeedImageViewModel<Image>(
            description: model.description,
            location: model.location,
            image: nil,
            shouldRetry: true))
        loadingView.display(FeedImageLoadingViewModel(isLoading: false))
    }
    
    public static func map(_ image: FeedImage) -> FeedImageViewModel<Image> {
        FeedImageViewModel<Image>(
            description: image.description,
            location: image.location,
            image: nil,
            shouldRetry: false)
    }
}
