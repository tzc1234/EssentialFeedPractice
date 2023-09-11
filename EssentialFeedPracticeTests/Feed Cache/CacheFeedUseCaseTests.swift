//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedPracticeTests
//
//  Created by Tsz-Lung on 10/09/2023.
//

import XCTest
import EssentialFeedPractice

class LocalFeedLoader {
    init(store: FeedStore) {
        
    }
}

class FeedStore {
    private(set) var messages = [Any]()
}

final class CacheFeedUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStore() {
        let store = FeedStore()
        _ = LocalFeedLoader(store: store)
        
        XCTAssertTrue(store.messages.isEmpty)
    }
}
