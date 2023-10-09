//
//  CoreDataFeedImageDataStoreTests.swift
//  EssentialFeedPracticeTests
//
//  Created by Tsz-Lung on 09/10/2023.
//

import XCTest
import EssentialFeedPractice

extension CoreDataFeedStore: FeedImageDataStore {
    public func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
        
    }
    
    public func retrieveData(for url: URL, completion: @escaping (RetrievalResult) -> Void) {
        completion(.success(.none))
    }
}

final class CoreDataFeedImageDataStoreTests: XCTestCase {
    func test_retrieveImageData_deliversNoDataWhenCacheEmpty() {
        let sut = makeSUT()
        
        expect(sut, toRetrieveWith: .success(.none), for: anyURL())
    }
    
    func test_retrieveImageData_deliversNoDataWhenStoreDataURLDoesNotMatch() {
        let sut = makeSUT()
        let url = URL(string: "http://a-url.com")!
        let notMatchingURL = URL(string: "http://another-url.com")!
        
        insert(anyData(), for: url, into: sut)
        
        expect(sut, toRetrieveWith: .success(.none), for: notMatchingURL)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CoreDataFeedStore {
        let sut = try! CoreDataFeedStore(storeURL: URL(filePath: "/dev/null"))
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func expect(_ sut: FeedImageDataStore,
                        toRetrieveWith expectedResult: FeedImageDataStore.RetrievalResult,
                        for url: URL,
                        file: StaticString = #filePath,
                        line: UInt = #line) {
        let exp = expectation(description: "Wait for retrieval")
        sut.retrieveData(for: url) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
            default:
                XCTFail("Expect result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
    
    private func insert(_ data: Data, for url: URL, into sut: CoreDataFeedStore,
                        file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for insertion")
        let image = localImage(url: url)
        sut.insert([image], timestamp: Date()) { result in
            switch result {
            case .success:
                sut.insert(data, for: url) { result in
                    switch result {
                    case .success:
                        break
                    case let .failure(error):
                        XCTFail("Failed to insert \(data) with error \(error)", file: file, line: line)
                    }
                }
            case let .failure(error):
                XCTFail("Failed to save \(image) with error \(error)", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
    
    private func localImage(url: URL) -> LocalFeedImage {
        LocalFeedImage(id: UUID(), description: "any", location: "any", url: url)
    }
}
