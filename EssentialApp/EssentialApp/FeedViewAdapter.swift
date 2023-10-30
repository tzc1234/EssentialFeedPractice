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
    private let selection: (FeedImage) -> Void
    
    init(controller: ListViewController,
         imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher,
         selection: @escaping (FeedImage) -> Void) {
        self.controller = controller
        self.imageLoader = imageLoader
        self.selection = selection
    }
    
    func display(_ viewModel: FeedViewModel) {
        controller?.display(viewModel.feed.map { model in
            let adapter = ImageDataPresentationAdapter(
                loader: { [imageLoader] in
                    imageLoader(model.url)
                })
            
            let view = FeedImageCellController(
                viewModel: FeedImagePresenter.map(model),
                delegate: adapter,
                selection: { [selection] in
                    selection(model)
                })
            
            adapter.presenter = LoadResourcePresenter(
                view: WeakRefProxy(view),
                loadingView: WeakRefProxy(view),
                errorView: WeakRefProxy(view),
                mapper: UIImage.tryMake)
            
            return CellController(id: model, view)
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
