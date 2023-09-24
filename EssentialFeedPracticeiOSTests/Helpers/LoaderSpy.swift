//
//  LoaderSpy.swift
//  EssentialFeedPracticeiOSTests
//
//  Created by Tsz-Lung on 23/09/2023.
//

import Foundation
import EssentialFeedPractice
import EssentialFeedPracticeiOS

final class LoaderSpy: FeedLoader, FeedImageDataLoader {
    // MARK: - FeedLoader
    
    private var feedRequests = [(FeedLoader.Result) -> Void]()
    
    var loadFeedCallCount: Int {
        feedRequests.count
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        feedRequests.append(completion)
    }
    
    func completeFeedLoading(with feed: [FeedImage] = [], at index: Int = 0) {
        feedRequests[index](.success(feed))
    }
    
    func completeFeedLoadingWithError(at index: Int = 0) {
        feedRequests[index](.failure(anyNSError()))
    }
    
    // MARK: - FeedImageDataLoader
    
    private(set) var cancelledImageURLs = [URL]()
    private(set) var imageRequests = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
    var loadedImageURLs: [URL] {
        imageRequests.map(\.url)
    }
    
    private struct Task: FeedImageDataLoaderTask {
        let afterCancel: () -> Void
        
        func cancel() {
            afterCancel()
        }
    }
    
    func loadImage(from url: URL,
                   completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        imageRequests.append((url, completion))
        return Task { [weak self] in
            self?.cancelledImageURLs.append(url)
        }
    }
    
    func completeImageLoading(with data: Data = Data(), at index: Int = 0) {
        imageRequests[index].completion(.success(data))
    }
    
    func completeImageLoadingWithError(at index: Int = 0) {
        imageRequests[index].completion(.failure(anyNSError()))
    }
}
