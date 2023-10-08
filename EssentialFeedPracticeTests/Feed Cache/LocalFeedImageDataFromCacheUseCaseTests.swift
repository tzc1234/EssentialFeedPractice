//
//  LocalFeedImageDataFromCacheUseCaseTests.swift
//  EssentialFeedPracticeTests
//
//  Created by Tsz-Lung on 08/10/2023.
//

import XCTest

typealias FeedImageDataStore = LocalFeedImageDataFromCacheUseCaseTests.FeedImageDataStoreSpy

final class LocalFeedImageDataLoader {
    private let store: FeedImageDataStore
    
    init(store: FeedImageDataStore) {
        self.store = store
    }
    
    func loadImageData(from url: URL) {
        store.retrieveData(for: url)
    }
}

final class LocalFeedImageDataFromCacheUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStoreUponCreation() {
        let store = FeedImageDataStoreSpy()
        _ = LocalFeedImageDataLoader(store: store)
        
        XCTAssertTrue(store.messages.isEmpty)
    }
    
    func test_loadImageDataFromURL_requestsStoredDataForURL() {
        let store = FeedImageDataStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        let url = anyURL()
        
        sut.loadImageData(from: url)
        
        XCTAssertEqual(store.messages, [.retrieveData(for: url)])
    }
    
    // MARK: - Helpers
    
    class FeedImageDataStoreSpy {
        enum Message: Equatable {
            case retrieveData(for: URL)
        }
        
        private(set) var messages = [Message]()
        
        func retrieveData(for url: URL) {
            messages.append(.retrieveData(for: url))
        }
    }
}
