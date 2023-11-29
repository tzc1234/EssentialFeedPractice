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
    
    // MARK: - LocalFeedLoader Tests
    
    func test_load_deliversEmptyFeedOnEmptyCache() {
        let feedLoader = makeFeedLoader()
        
        expect(feedLoader, toLoad: [])
    }
    
    func test_load_deliversFeedSavedOnASeparateInstance() {
        let feedLoaderToPerformSave = makeFeedLoader()
        let feedLoaderToPerformLoad = makeFeedLoader()
        let feed = uniqueFeed().models
        
        save(feed, with: feedLoaderToPerformSave)
        
        expect(feedLoaderToPerformLoad, toLoad: feed)
    }
    
    func test_save_overridesFeedSavedOnASeparateInstance() {
        let feedLoaderToPerformFirstSave = makeFeedLoader()
        let feedLoaderToPerformLastSave = makeFeedLoader()
        let feedLoaderToPerformLoad = makeFeedLoader()
        let firstFeed = uniqueFeed().models
        let latestFeed = uniqueFeed().models
        
        save(firstFeed, with: feedLoaderToPerformFirstSave)
        save(latestFeed, with: feedLoaderToPerformLastSave)
        
        expect(feedLoaderToPerformLoad, toLoad: latestFeed)
    }
    
    func test_validateFeedCache_doesNotDeleteRecentlySavedFeed() {
        let feedLoaderToPerformSave = makeFeedLoader()
        let feedLoaderToPerformValidation = makeFeedLoader()
        let feed = uniqueFeed().models
        
        save(feed, with: feedLoaderToPerformSave)
        validateCache(with: feedLoaderToPerformValidation)
        
        expect(feedLoaderToPerformSave, toLoad: feed)
    }
    
    func test_validateFeedCache_deletesFeedSavedInADistancePast() {
        let feedLoaderToPerformSave = makeFeedLoader(currentDate: .distantPast)
        let feedLoaderToPerformValidation = makeFeedLoader(currentDate: .now)
        let feed = uniqueFeed().models
        
        save(feed, with: feedLoaderToPerformSave)
        validateCache(with: feedLoaderToPerformValidation)
        
        expect(feedLoaderToPerformSave, toLoad: [])
    }
    
    // MARK: - LocalFeedImageDataLoader Tests
    
    func test_loadImageData_deliversSavedDataOnASeparateInstance() {
        let imageLoaderToPerformSave = makeImageLoader()
        let imageLoaderToPerformLoad = makeImageLoader()
        let feedLoader = makeFeedLoader()
        let image = uniqueFeedImage()
        let dataToSave = anyData()
        
        save([image], with: feedLoader)
        save(dataToSave, for: image.url, with: imageLoaderToPerformSave)
        
        expect(imageLoaderToPerformLoad, toLoad: dataToSave, for: image.url)
    }
    
    func test_saveImageData_overridesSavedDataOnASeparateInstance() {
        let imageLoaderToPerFormFirstSave = makeImageLoader()
        let imageLoaderToPerFormLastSave = makeImageLoader()
        let imageLoaderToPerformLoad = makeImageLoader()
        let feedLoader = makeFeedLoader()
        let image = uniqueFeedImage()
        let firstImageData = Data("first".utf8)
        let lastImageData = Data("last".utf8)
        
        save([image], with: feedLoader)
        save(firstImageData, for: image.url, with: imageLoaderToPerFormFirstSave)
        save(lastImageData, for: image.url, with: imageLoaderToPerFormLastSave)
        
        expect(imageLoaderToPerformLoad, toLoad: lastImageData, for: image.url)
    }
    
    // MARK: - Helpers
    
    private func makeFeedLoader(currentDate: Date = Date(),
                                file: StaticString = #filePath,
                                line: UInt = #line) -> LocalFeedLoader {
        let store = try! CoreDataFeedStore(storeURL: testSpecificStoreURL())
        let sut = LocalFeedLoader(store: store, currentDate: { currentDate })
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func makeImageLoader(file: StaticString = #filePath, line: UInt = #line) -> LocalFeedImageDataLoader {
        let store = try! CoreDataFeedStore(storeURL: testSpecificStoreURL())
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func validateCache(with sut: LocalFeedLoader, file: StaticString = #filePath, line: UInt = #line) {
        do {
            try sut.validateCache()
        } catch {
            XCTFail("Expect to validate feed successfully, got \(error) instead", file: file, line: line)
        }
    }
    
    private func save(_ feed: [FeedImage], with sut: LocalFeedLoader,
                      file: StaticString = #filePath, line: UInt = #line) {
        do {
            try sut.save(feed)
        } catch {
            XCTFail("Expect a success, got \(error) instead", file: file, line: line)
        }
    }
    
    private func save(_ data: Data, for url: URL, with sut: LocalFeedImageDataLoader,
                      file: StaticString = #filePath, line: UInt = #line) {
        do {
            try sut.save(data, for: url)
        } catch {
            XCTFail("Expect to save image data successfully, got \(error) instead", file: file, line: line)
        }
    }
    
    private func expect(_ sut: LocalFeedLoader, toLoad feed: [FeedImage],
                        file: StaticString = #filePath, line: UInt = #line) {
        do {
            let receivedFeed = try sut.load()
            XCTAssertEqual(receivedFeed, feed, file: file, line: line)
        } catch {
            XCTFail("Expect a success, got \(error) instead", file: file, line: line)
        }
    }
    
    private func expect(_ sut: LocalFeedImageDataLoader, toLoad data: Data, for url: URL,
                        file: StaticString = #filePath, line: UInt = #line) {
        do {
            let receivedData = try sut.loadImageData(from: url)
            XCTAssertEqual(receivedData, data, file: file, line: line)
        } catch {
            XCTFail("Expect a successful image data, got \(error) instead", file: file, line: line)
        }
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
