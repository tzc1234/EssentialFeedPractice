//
//  RemoteLoaderTests.swift
//  EssentialFeedPracticeTests
//
//  Created by Tsz-Lung on 24/10/2023.
//

import XCTest
import EssentialFeedPractice

final class RemoteLoaderTests: XCTestCase {
    func test_init_doesNotRequestFromClientUponCreation() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.loggedURLs.isEmpty)
    }
    
    func test_load_requestsFromURL() {
        let url = URL(string: "https://an-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        
        XCTAssertEqual(client.loggedURLs, [url])
    }
    
    func test_load_deliversConnectivityErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: failure(.connectivity), when: {
            client.complete(with: anyNSError())
        })
    }
    
    func test_load_deliversInvalidDataErrorWhenReceivedInvalidDataFromClient() {
        let (sut, client) = makeSUT()
        let invalidData = Data("invalid data".utf8)
        
        expect(sut, toCompleteWith: failure(.invalidData), when: {
            client.complete(with: invalidData)
        })
    }
    
    func test_load_deliversInvalidDataErrorWhenNon200ResponseFromClient() {
        let (sut, client) = makeSUT()
        let simple = [100, 199, 201, 300, 400, 500]
        
        simple.enumerated().forEach { index, statusCode in
            expect(sut, toCompleteWith: .failure(RemoteLoader.Error.invalidData), when: {
                client.complete(with: anyData(), statusCode: statusCode, at: index)
            })
        }
    }
    
    func test_load_deliversEmptyFeedWhenReceivedEmptyItemsDataFromClient() {
        let (sut, client) = makeSUT()
        let emptyFeed = [FeedImage]()
        let emptyItemsData = makeJSONData([])
        
        expect(sut, toCompleteWith: .success(emptyFeed), when: {
            client.complete(with: emptyItemsData)
        })
    }
    
    func test_load_deliversOneFeedImageWhenReceivedOneItemDataFromClient() {
        let (sut, client) = makeSUT()
        let items = [makeFeedItem(url: URL(string: "https://an-url.com")!)]
        let feed = items.map(\.image)
        let oneItemData = makeJSONData(items.map(\.json))
        
        expect(sut, toCompleteWith: .success(feed), when: {
            client.complete(with: oneItemData)
        })
    }
    
    func test_load_deliversFeedWhenReceivedMultipleItemsDataFromClient() {
        let (sut, client) = makeSUT()
        let items = [
            makeFeedItem(url: URL(string: "https://an-url.com")!),
            makeFeedItem(
                description: "an description",
                location: "a location",
                url: URL(string: "https://another-url.com")!)
        ]
        let feed = items.map(\.image)
        let itemsData = makeJSONData(items.map(\.json))
        
        expect(sut, toCompleteWith: .success(feed), when: {
            client.complete(with: itemsData)
        })
    }
    
    func test_load_doesNotDeliverFeedAfterSUTInstanceIsDeallocated() {
        let client = HTTPClientSpy()
        var sut: RemoteLoader? = RemoteLoader(client: client, url: anyURL())
        
        var completionCount = 0
        sut?.load { _ in completionCount += 1 }
        sut = nil
        client.complete(with: anyData())
        
        XCTAssertEqual(completionCount, 0)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL? = nil,
                         file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: RemoteLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteLoader(client: client, url: url ?? anyURL())
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, client)
    }
    
    private func failure(_ error: RemoteLoader.Error) -> FeedLoader.Result {
        .failure(error)
    }
    
    private func makeFeedItem(id: UUID = UUID(),
                              description: String? = nil,
                              location: String? = nil,
                              url: URL) -> (image: FeedImage, json: [String: Any]) {
        let image = FeedImage(id: id, description: description, location: location, url: url)
        let json: [String: Any] = [
            "id": image.id.uuidString,
            "description": image.description,
            "location": image.location,
            "image": image.url.absoluteString
        ].compactMapValues { $0 }
        return (image, json)
    }
    
    private func makeJSONData(_ items: [[String: Any]]) -> Data {
        let json: [String: Any] = ["items": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func expect(_ sut: RemoteLoader,
                        toCompleteWith expectedResult: FeedLoader.Result,
                        when action: () -> Void,
                        file: StaticString = #filePath,
                        line: UInt = #line) {
        let exp = expectation(description: "Wait for completion")
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedFeed), .success(expectedFeed)):
                XCTAssertEqual(receivedFeed, expectedFeed, file: file, line: line)
            case let (.failure(receivedError as RemoteLoader.Error),
                .failure(expectedError as RemoteLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expect \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1)
    }
}
