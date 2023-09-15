//
//  EssentialFeedPracticeCacheIntegrationTests.swift
//  EssentialFeedPracticeCacheIntegrationTests
//
//  Created by Tsz-Lung on 15/09/2023.
//

import XCTest
import EssentialFeedPractice

final class EssentialFeedPracticeCacheIntegrationTests: XCTestCase {
    func test_load_deliversEmptyFeedOnEmptyCache() {
        let sut = makeSUT()
        
        let exp = expectation(description: "Wait for load completion")
        sut.load { result in
            switch result {
            case let .success(feed):
                XCTAssertEqual(feed, [])
            case let .failure(error):
                XCTFail("Expect a success, got \(error) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> LocalFeedLoader {
        let store = try! CoreDataFeedStore(storeURL: testSpecificStoreURL())
        let sut = LocalFeedLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func testSpecificStoreURL() -> URL {
        cachesDirectory().appending(path: "\(String(describing: Self.self)).store")
    }
    
    private func cachesDirectory() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}
