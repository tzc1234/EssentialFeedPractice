//
//  FeedImageDataLoaderCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by Tsz-Lung on 12/10/2023.
//

import XCTest
import EssentialFeedPractice

final class FeedImageDataLoaderCacheDecorator: FeedImageDataLoader {
    private let decoratee: FeedImageDataLoader
    
    init(decoratee: FeedImageDataLoader) {
        self.decoratee = decoratee
    }
    
    private struct TaskWrapper: FeedImageDataLoaderTask {
        let wrapped: FeedImageDataLoaderTask
        
        func cancel() {
            wrapped.cancel()
        }
    }
    
    func loadImageData(from url: URL,
                       completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        TaskWrapper(wrapped: decoratee.loadImageData(from: url) { _ in })
    }
}

final class FeedImageDataLoaderCacheDecoratorTests: XCTestCase {
    func test_init_doesNotLoadImageData() {
        let (_, loader) = makeSUT()
        
        XCTAssertTrue(loader.loadedURLs.isEmpty)
    }
    
    func test_loadImageData_loadsFromLoader() {
        let (sut, loader) = makeSUT()
        let url = anyURL()
        
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(loader.loadedURLs, [url])
    }
    
    func test_cancelLoadImageData_cancelsLoaderTask() {
        let (sut, loader) = makeSUT()
        let url = anyURL()
        
        let task = sut.loadImageData(from: url) { _ in }
        task.cancel()
        
        XCTAssertEqual(loader.cancelledURLs, [url])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: FeedImageDataLoader, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedImageDataLoaderCacheDecorator(decoratee: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    private class LoaderSpy: FeedImageDataLoader {
        private var messages = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
        var loadedURLs: [URL] {
            messages.map(\.url)
        }
        
        private(set) var cancelledURLs = [URL]()
        
        private struct Task: FeedImageDataLoaderTask {
            let afterCancel: () -> Void
            
            func cancel() {
                afterCancel()
            }
        }
        
        func loadImageData(from url: URL,
                           completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
            messages.append((url, completion))
            return Task { [weak self] in
                self?.cancelledURLs.append(url)
            }
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(with data: Data, at index: Int = 0) {
            messages[index].completion(.success(data))
        }
    }
}
