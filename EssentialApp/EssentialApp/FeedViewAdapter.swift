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

final class FeedViewAdapter: ResourceView {
    private typealias ImageDataPresentationAdapter = LoadResourcePresentationAdapter<Data, WeakRefProxy<FeedImageCellController>>
    
    private weak var controller: FeedViewController?
    private let imageLoader: (URL) -> FeedImageDataLoader.Publisher
    
    init(controller: FeedViewController? = nil, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func display(_ viewModel: FeedViewModel) {
        controller?.display(viewModel.feed.map { model in
            let adapter = ImageDataPresentationAdapter(
                loader: { [imageLoader] in
                    imageLoader(model.url)
                })
            
            let controller = FeedImageCellController(viewModel: FeedImagePresenter.map(model), delegate: adapter)
            
            adapter.presenter = LoadResourcePresenter(
                view: WeakRefProxy(controller),
                loadingView: WeakRefProxy(controller),
                errorView: WeakRefProxy(controller),
                mapper: { data in
                    guard let image = UIImage(data: data) else {
                        throw InvalidImageDataError()
                    }
                    
                    return image
                })
            
            return controller
        })
    }
}

private struct InvalidImageDataError: Error {}
