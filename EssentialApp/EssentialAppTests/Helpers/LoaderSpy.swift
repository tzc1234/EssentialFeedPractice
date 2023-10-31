//
//  LoaderSpy.swift
//  EssentialFeedPracticeiOSTests
//
//  Created by Tsz-Lung on 23/09/2023.
//

import Combine
import Foundation
import EssentialFeedPractice
import EssentialFeedPracticeiOS

final class LoaderSpy: FeedImageDataLoader {
    private var feedRequests = [PassthroughSubject<Paginated<FeedImage>, Error>]()
    var loadFeedCallCount: Int {
        feedRequests.count
    }
    
    func loadPublisher() -> AnyPublisher<Paginated<FeedImage>, Error> {
        let publisher = PassthroughSubject<Paginated<FeedImage>, Error>()
        feedRequests.append(publisher)
        return publisher.eraseToAnyPublisher()
    }
    
    func completeFeedLoading(with feed: [FeedImage] = [], at index: Int = 0) {
        feedRequests[index].send(Paginated(items: feed))
        feedRequests[index].send(completion: .finished)
    }
    
    func completeFeedLoadingWithError(at index: Int = 0) {
        feedRequests[index].send(completion: .failure(anyNSError()))
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
    
    func loadImageData(from url: URL,
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
