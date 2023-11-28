//
//  CoreDataFeedImageDataStoreTests.swift
//  EssentialFeedPracticeTests
//
//  Created by Tsz-Lung on 09/10/2023.
//

import XCTest
import EssentialFeedPractice

final class CoreDataFeedImageDataStoreTests: XCTestCase {
    func test_retrieveImageData_deliversNoDataWhenCacheEmpty() {
        let sut = makeSUT()
        
        expect(sut, toRetrieveWith: noData(), for: anyURL())
    }
    
    func test_retrieveImageData_deliversNoDataWhenStoreDataURLDoesNotMatch() {
        let sut = makeSUT()
        let url = URL(string: "http://a-url.com")!
        let notMatchingURL = URL(string: "http://another-url.com")!
        
        insert(anyData(), for: url, into: sut)
        
        expect(sut, toRetrieveWith: noData(), for: notMatchingURL)
    }
    
    func test_retrieveImageData_deliversDataWhenThereIsAStoredImageDataMatchingURL() {
        let sut = makeSUT()
        let storedData = anyData()
        let matchingURL =  URL(string: "http://a-url.com")!
        
        insert(storedData, for: matchingURL, into: sut)
        
        expect(sut, toRetrieveWith: found(storedData), for: matchingURL)
    }
    
    func test_retrieveImageData_deliversLastInsertedData() {
        let sut = makeSUT()
        let firstStoredData = Data("first".utf8)
        let lastStoredData = Data("last".utf8)
        let url = URL(string: "http://a-url.com")!
        
        insert(firstStoredData, for: url, into: sut)
        insert(lastStoredData, for: url, into: sut)
        
        expect(sut, toRetrieveWith: found(lastStoredData), for: url)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CoreDataFeedStore {
        let sut = try! CoreDataFeedStore(storeURL: URL(filePath: "/dev/null"))
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func expect(_ sut: FeedImageDataStore,
                        toRetrieveWith expectedResult: Result<Data?, Error>,
                        for url: URL,
                        file: StaticString = #filePath,
                        line: UInt = #line) {
        let receivedResult = Result { try sut.retrieveData(for: url) }
        
        switch (receivedResult, expectedResult) {
        case let (.success(receivedData), .success(expectedData)):
            XCTAssertEqual(receivedData, expectedData, file: file, line: line)
        default:
            XCTFail("Expect result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
        }
    }
    
    private func insert(_ data: Data, for url: URL, into sut: CoreDataFeedStore,
                        file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for insertion")
        let image = localImage(url: url)
        sut.insert([image], timestamp: Date()) { result in
            if case let .failure(error) = result {
                XCTFail("Failed to save \(image) with error \(error)", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
        
        do {
            try sut.insert(data, for: url)
        } catch {
            XCTFail("Failed to insert \(data) with error \(error)", file: file, line: line)
        }
    }
    
    private func localImage(url: URL) -> LocalFeedImage {
        LocalFeedImage(id: UUID(), description: "any", location: "any", url: url)
    }
    
    private func noData() -> Result<Data?, Error> {
        .success(.none)
    }
    
    private func found(_ data: Data) -> Result<Data?, Error> {
        .success(data)
    }
}
