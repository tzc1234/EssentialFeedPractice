//
//  FeedImagePresenter.swift
//  EssentialFeedPracticeiOS
//
//  Created by Tsz-Lung on 28/09/2023.
//

import Foundation
import EssentialFeedPractice

struct FeedImageViewModel<Image> {
    let description: String?
    let location: String?
    let image: Image?
    let shouldRetry: Bool
}

protocol FeedImageView {
    associatedtype Image
    
    func display(_ viewModel: FeedImageViewModel<Image>)
}

struct FeedImageLoadingViewModel {
    let isLoading: Bool
}

protocol FeedImageLoadingView {
    func display(_ viewModel: FeedImageLoadingViewModel)
}

final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    private let view: View
    private let loadingView: FeedImageLoadingView
    private let imageTransformer: (Data) -> Image?
    
    init(view: View, loadingView: FeedImageLoadingView, imageTransformer: @escaping (Data) -> Image?) {
        self.view = view
        self.loadingView = loadingView
        self.imageTransformer = imageTransformer
    }
    
    func didStartLoadingImageData(for model: FeedImage) {
        loadingView.display(FeedImageLoadingViewModel(isLoading: true))
        view.display(FeedImageViewModel<Image>(
            description: model.description,
            location: model.location,
            image: nil,
            shouldRetry: false))
    }
    
    func didFinishLoadingImageData(with data: Data, for model: FeedImage) {
        let image = imageTransformer(data)
        view.display(FeedImageViewModel<Image>(
            description: model.description,
            location: model.location,
            image: image,
            shouldRetry: image == nil))
        loadingView.display(FeedImageLoadingViewModel(isLoading: false))
    }
    
    func didFinishLoadingImageData(with error: Error, for model: FeedImage) {
        view.display(FeedImageViewModel<Image>(
            description: model.description,
            location: model.location,
            image: nil,
            shouldRetry: true))
        loadingView.display(FeedImageLoadingViewModel(isLoading: false))
    }
}
