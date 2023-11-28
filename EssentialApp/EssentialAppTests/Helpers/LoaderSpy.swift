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

final class LoaderSpy {
    private var feedRequests = [PassthroughSubject<Paginated<FeedImage>, Error>]()
    private var loadMoreRequests = [PassthroughSubject<Paginated<FeedImage>, Error>]()
    
    var loadFeedCallCount: Int {
        feedRequests.count
    }
    
    var loadMoreCallCount: Int {
        loadMoreRequests.count
    }
    
    func loadPublisher() -> AnyPublisher<Paginated<FeedImage>, Error> {
        let publisher = PassthroughSubject<Paginated<FeedImage>, Error>()
        feedRequests.append(publisher)
        return publisher.eraseToAnyPublisher()
    }
    
    func completeFeedLoading(with feed: [FeedImage] = [], at index: Int = 0) {
        feedRequests[index].send(makePaginatedFeed(with: feed))
        feedRequests[index].send(completion: .finished)
    }
    
    func completeFeedLoadingWithError(at index: Int = 0) {
        feedRequests[index].send(completion: .failure(anyNSError()))
    }
    
    func completeLoadMore(with feed: [FeedImage] = [], isLastPage: Bool = false, at index: Int = 0) {
        loadMoreRequests[index].send(makePaginatedFeed(with: feed, isLastPage: isLastPage))
        loadMoreRequests[index].send(completion: .finished)
    }
    
    func completeLoadMoreWithError(at index: Int = 0) {
        loadMoreRequests[index].send(completion: .failure(anyNSError()))
    }
    
    private func makePaginatedFeed(with feed: [FeedImage], isLastPage: Bool = false) -> Paginated<FeedImage> {
        Paginated(
            items: feed,
            loadMorePublisher: isLastPage ? nil : { [weak self] in
                let publisher = PassthroughSubject<Paginated<FeedImage>, Error>()
                self?.loadMoreRequests.append(publisher)
                return publisher.eraseToAnyPublisher()
            })
    }
    
    // MARK: - FeedImageDataLoader
    
    private(set) var cancelledImageURLs = [URL]()
    private(set) var imageRequests = [(url: URL, publisher: PassthroughSubject<Data, Error>)]()
    var loadedImageURLs: [URL] {
        imageRequests.map(\.url)
    }
    
    func loadImageDataPublisher(from url: URL) -> AnyPublisher<Data, Error> {
        let publisher = PassthroughSubject<Data, Error>()
        imageRequests.append((url, publisher))
        return publisher
            .handleEvents(receiveCancel: { [weak self] in
                self?.cancelledImageURLs.append(url)
            })
            .eraseToAnyPublisher()
    }
    
    func completeImageLoading(with data: Data = Data(), at index: Int = 0) {
        imageRequests[index].publisher.send(data)
        imageRequests[index].publisher.send(completion: .finished)
    }
    
    func completeImageLoadingWithError(at index: Int = 0) {
        imageRequests[index].publisher.send(completion: .failure(anyNSError()))
    }
}
