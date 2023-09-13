//
//  CodableFeedStoreTests.swift
//  EssentialFeedPracticeTests
//
//  Created by Tsz-Lung on 13/09/2023.
//

import XCTest
import EssentialFeedPractice

class CodableFeedStore {
    func retrieve(completion: @escaping FeedStore.RetrieveCompletion) {
        completion(.success(.none))
    }
}

final class CodableFeedStoreTests: XCTestCase {
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = CodableFeedStore()
        
        let exp = expectation(description: "Wait for cache retrieval")
        sut.retrieve { result in
            switch result {
            case let .success(cache):
                XCTAssertNil(cache)
            case .failure:
                XCTFail("Expect a success")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
}
