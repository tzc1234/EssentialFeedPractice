//
//  EssentialFeedPracticeCacheIntegrationTests.swift
//  EssentialFeedPracticeCacheIntegrationTests
//
//  Created by Tsz-Lung on 15/09/2023.
//

import XCTest
import EssentialFeedPractice

final class EssentialFeedPracticeCacheIntegrationTests: XCTestCase {
    override func setUp() {
        super.setUp()
        
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        
        undoStoreSideEffects()
    }
    
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
    
    func test_load_deliversFeedSavedOnASeparateInstance() {
        let sutToPerformSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let feed = uniqueFeed().models
        
        let saveExp = expectation(description: "Wait for save completion")
        sutToPerformSave.save(feed) { result in
            switch result {
            case .success:
                break
            case let .failure(error):
                XCTFail("Expect a success, got \(error) instead")
            }
            saveExp.fulfill()
        }
        wait(for: [saveExp], timeout: 1)
        
        let loadExp = expectation(description: "Wait for load completion")
        sutToPerformLoad.load { result in
            switch result {
            case let .success(receivedFeed):
                XCTAssertEqual(receivedFeed, feed)
            case let .failure(error):
                XCTFail("Expect a success, got \(error) instead")
            }
            loadExp.fulfill()
        }
        wait(for: [loadExp], timeout: 1)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> LocalFeedLoader {
        let store = try! CoreDataFeedStore(storeURL: testSpecificStoreURL())
        let sut = LocalFeedLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func setupEmptyStoreState() {
        deleteCacheStoreArtefacts()
    }
    
    private func undoStoreSideEffects() {
        deleteCacheStoreArtefacts()
    }
    
    private func deleteCacheStoreArtefacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
    private func testSpecificStoreURL() -> URL {
        cachesDirectory().appending(path: "\(String(describing: Self.self)).store")
    }
    
    private func cachesDirectory() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}
