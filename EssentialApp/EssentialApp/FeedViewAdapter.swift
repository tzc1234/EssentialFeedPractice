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
    private typealias LoadMorePresentationAdapter = LoadResourcePresentationAdapter<Paginated<FeedImage>, FeedViewAdapter>
    
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
    
    func display(_ viewModel: Paginated<FeedImage>) {
        let feedSection: [CellController] = viewModel.items.map { model in
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
                resourceView: WeakRefProxy(view),
                loadingView: WeakRefProxy(view),
                errorView: WeakRefProxy(view),
                mapper: UIImage.tryMake)
            
            return CellController(id: model, view)
        }
        
        guard let loadMorePublisher = viewModel.loadMorePublisher else {
            controller?.display(feedSection)
            return
        }
        
        let loadMoreAdapter = LoadMorePresentationAdapter(loader: loadMorePublisher)
        let loadMore = LoadMoreCellController(callback: loadMoreAdapter.loadResource)
        
        loadMoreAdapter.presenter = LoadResourcePresenter(
            resourceView: self,
            loadingView: WeakRefProxy(loadMore),
            errorView: WeakRefProxy(loadMore),
            mapper: { $0 })
        
        let loadMoreSection = [CellController(id: UUID(), loadMore)]
        
        controller?.display(feedSection, loadMoreSection)
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
