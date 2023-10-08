//
//  CacheFeedImageDataUseCaseTests.swift
//  EssentialFeedPracticeTests
//
//  Created by Tsz-Lung on 08/10/2023.
//

import XCTest
import EssentialFeedPractice

final class CacheFeedImageDataUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.messages.isEmpty)
    }
    
    func test_saveImageDataForURL_requestsImageDataInsertionForURL() {
        let (sut, store) = makeSUT()
        let url = anyURL()
        let data = anyData()
        
        sut.save(data, for: url) { _ in }
        
        XCTAssertEqual(store.messages, [.insert(data: data, for: url)])
    }
    
//    func test_saveImageDataForURL_failsOnStoreInsertionError() {
//        let (sut, store) = makeSUT()
//        let expectedResult: LocalFeedImageDataLoader.SaveResult = .failure(LocalFeedImageDataLoader.SaveError.failed)
//        
//        let exp = expectation(description: "Wait for save completion")
//        sut.save(anyData(), for: anyURL()) { receivedResult in
//            switch (receivedResult, expectedResult) {
//            case (.success, .success):
//                break
//            case let (.failure(receivedError), .failure(expectedError)):
//                
//            }
//            exp.fulfill()
//        }
//        store.completeInsertion(with: anyNSError())
//        wait(for: [exp], timeout: 1)
//    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: FeedImageDataStoreSpy) {
        let store = FeedImageDataStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
}
