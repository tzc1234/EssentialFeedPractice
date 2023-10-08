//
//  LocalFeedImageDataFromCacheUseCaseTests.swift
//  EssentialFeedPracticeTests
//
//  Created by Tsz-Lung on 08/10/2023.
//

import XCTest

final class LocalFeedImageDataLoader {
    init(store: Any) {
        
    }
}

final class LocalFeedImageDataFromCacheUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStoreUponCreation() {
        let store = FeedImageDataStoreSpy()
        _ = LocalFeedImageDataLoader(store: store)
        
        XCTAssertTrue(store.messages.isEmpty)
    }
    
    // MARK: - Helpers
    
    private class FeedImageDataStoreSpy {
        private(set) var messages = [Any]()
    }
}
