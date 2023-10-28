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
    
    private weak var controller: ListViewController?
    private let imageLoader: (URL) -> FeedImageDataLoader.Publisher
    
    init(controller: ListViewController, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) {
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
                mapper: UIImage.tryMake)
            
            return CellController(controller)
        })
    }
}

extension UIImage {
    struct InvalidImageDataError: Error {}
    
    static func tryMake(data: Data) throws -> UIImage {
        guard let image = UIImage(data: data) else {
            throw InvalidImageDataError()
        }
        
        return image
    }
}
