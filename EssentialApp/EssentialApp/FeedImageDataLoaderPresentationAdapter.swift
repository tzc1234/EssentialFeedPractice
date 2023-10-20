//
//  FeedImageDataLoaderPresentationAdapter.swift
//  EssentialFeedPracticeiOS
//
//  Created by Tsz-Lung on 28/09/2023.
//

import Combine
import Foundation
import EssentialFeedPractice
import EssentialFeedPracticeiOS

final class FeedImageDataLoaderPresentationAdapter<View: FeedImageView, Image> where View.Image == Image {
    private var cancellable: AnyCancellable?
    var presenter: FeedImagePresenter<View, Image>?
    
    private let model: FeedImage
    private let imageLoader: (URL) -> FeedImageDataLoader.Publisher
    
    init(model: FeedImage, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) {
        self.model = model
        self.imageLoader = imageLoader
    }
}

extension FeedImageDataLoaderPresentationAdapter: FeedImageCellControllerDelegate {
    var hasNoImageRequest: Bool { cancellable == nil }
    
    func didRequestImage() {
        presenter?.didStartLoadingImageData(for: model)
        cancellable = imageLoader(model.url).sink { [weak presenter, model] completion in
            switch completion {
            case .finished:
                break
            case let .failure(error):
                presenter?.didFinishLoadingImageData(with: error, for: model)
            }
        } receiveValue: { [weak presenter, model] data in
            presenter?.didFinishLoadingImageData(with: data, for: model)
        }
    }
    
    func didCancelImageRequest() {
        cancellable?.cancel()
        cancellable = nil
    }
}
