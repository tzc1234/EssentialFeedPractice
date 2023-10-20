//
//  FeedViewAdapter.swift
//  EssentialFeedPracticeiOS
//
//  Created by Tsz-Lung on 28/09/2023.
//

import UIKit
import Combine
import EssentialFeedPractice
import EssentialFeedPracticeiOS

final class FeedViewAdapter: FeedView {
    private weak var controller: FeedViewController?
    private let imageLoader: (URL) -> FeedImageDataLoader.Publisher
    
    init(controller: FeedViewController? = nil, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func display(_ viewModel: FeedViewModel) {
        controller?.display(viewModel.feed.map { model in
            let adapter = FeedImageDataLoaderPresentationAdapter<WeakRefProxy<FeedImageCellController>, UIImage>(
                model: model,
                imageLoader: imageLoader)
            let controller = FeedImageCellController(delegate: adapter)
            adapter.presenter = FeedImagePresenter<WeakRefProxy<FeedImageCellController>, UIImage>(
                view: WeakRefProxy(controller),
                loadingView: WeakRefProxy(controller),
                imageTransformer: UIImage.init)
            return controller
        })
    }
}
