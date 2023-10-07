//
//  FeedImageDataLoaderPresentationAdapter.swift
//  EssentialFeedPracticeiOS
//
//  Created by Tsz-Lung on 28/09/2023.
//

import EssentialFeedPractice

final class FeedImageDataLoaderPresentationAdapter<View: FeedImageView, Image> where View.Image == Image {
    private var task: FeedImageDataLoaderTask?
    var presenter: FeedImagePresenter<View, Image>?
    
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader
    
    init(model: FeedImage, imageLoader: FeedImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
}

extension FeedImageDataLoaderPresentationAdapter: FeedImageCellControllerDelegate {
    var hasNoImageRequest: Bool { task == nil }
    
    func didRequestImage() {
        presenter?.didStartLoadingImageData(for: model)
        task = imageLoader.loadImageData(from: model.url) { [weak presenter, model] result in
            switch result {
            case let .success(data):
                presenter?.didFinishLoadingImageData(with: data, for: model)
            case let .failure(error):
                presenter?.didFinishLoadingImageData(with: error, for: model)
            }
        }
    }
    
    func didCancelImageRequest() {
        task?.cancel()
        task = nil
    }
}
