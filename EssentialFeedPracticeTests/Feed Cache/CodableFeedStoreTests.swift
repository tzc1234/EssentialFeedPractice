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
            case .success(.none):
                break
            default:
                XCTFail("Expect an empty result")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
    
    func test_retrieve_hasNoSideEffectOnEmptyCache() {
        let sut = CodableFeedStore()
        
        let exp = expectation(description: "Wait for cache retrieval")
        sut.retrieve { firstResult in
            sut.retrieve { secondResult in
                switch (firstResult, secondResult) {
                case (.success(.none), .success(.none)):
                    break
                default:
                    XCTFail("Expect both are empty result, got \(firstResult) and \(secondResult) instead")
                }
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 1)
    }
}
