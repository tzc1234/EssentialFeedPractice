//
//  FeedImageViewModel.swift
//  EssentialFeedPracticeiOS
//
//  Created by Tsz-Lung on 26/09/2023.
//

import UIKit
import EssentialFeedPractice

final class FeedImageViewModel<Image> {
    typealias Observer<T> = (T) -> Void
    
    private var task: FeedImageDataLoaderTask?
    var hasNoImageDataLoad: Bool { task == nil }
    var description: String? { model.description }
    var location: String? { model.location }
    
    var onLoading: Observer<Bool>?
    var onImageLoad: Observer<Image?>?
    var onShouldRetryImageLoad: Observer<Bool>?
    
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader
    private let imageTransformer: (Data) -> Image?
    
    init(model: FeedImage, imageLoader: FeedImageDataLoader, imageTransformer: @escaping (Data) -> Image?) {
        self.model = model
        self.imageLoader = imageLoader
        self.imageTransformer = imageTransformer
    }
    
    func loadImageData() {
        onLoading?(true)
        onImageLoad?(nil)
        onShouldRetryImageLoad?(false)
        task = imageLoader.loadImage(from: model.url) { [weak self] result in
            guard let self else { return }
            
            let image = convert(result)
            onLoading?(false)
            onImageLoad?(image)
            onShouldRetryImageLoad?(image == nil)
        }
    }
    
    private func convert(_ result: Result<Data, Error>) -> Image? {
        let data = try? result.get()
        return data.map(imageTransformer) ?? nil
    }
    
    func cancelImageDataLoad() {
        task?.cancel()
        task = nil
    }
}
