//
//  LoadFeedFromRemoteUseCaseTests.swift
//  EssentialFeedPracticeTests
//
//  Created by Tsz-Lung on 18/09/2023.
//

import XCTest
import EssentialFeedPractice

final class LoadFeedFromRemoteUseCaseTests: XCTestCase {
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
        
        expect(sut, toCompleteWith: .failure(RemoteFeedLoader.Error.connectivity), when: {
            client.complete(with: anyNSError())
        })
    }
    
    func test_load_deliversInvalidDataErrorWhenReceivedInvalidDataFromClient() {
        let (sut, client) = makeSUT()
        let invalidData = Data("invalid data".utf8)
        
        expect(sut, toCompleteWith: .failure(RemoteFeedLoader.Error.invalidData), when: {
            client.complete(with: invalidData)
        })
    }
    
    func test_load_deliversInvalidDataErrorWhenNon200ResponseFromClient() {
        let (sut, client) = makeSUT()
        let simple = [100, 199, 201, 300, 400, 500]
        
        simple.enumerated().forEach { index, statusCode in
            let non200Response = HTTPURLResponse(statusCode: statusCode)
            expect(sut, toCompleteWith: .failure(RemoteFeedLoader.Error.invalidData), when: {
                client.complete(with: anyData(), response: non200Response, at: index)
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
        let client = ClientSpy()
        var sut: RemoteFeedLoader? = RemoteFeedLoader(client: client, url: anyURL())
        
        var completionCount = 0
        sut?.load { _ in completionCount += 1 }
        sut = nil
        client.complete(with: anyData())
        
        XCTAssertEqual(completionCount, 0)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL? = nil,
                         file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: RemoteFeedLoader, client: ClientSpy) {
        let client = ClientSpy()
        let sut = RemoteFeedLoader(client: client, url: url ?? anyURL())
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, client)
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
    
    private func expect(_ sut: RemoteFeedLoader,
                        toCompleteWith expectedResult: FeedLoader.Result,
                        when action: () -> Void,
                        file: StaticString = #filePath,
                        line: UInt = #line) {
        let exp = expectation(description: "Wait for completion")
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedFeed), .success(expectedFeed)):
                XCTAssertEqual(receivedFeed, expectedFeed, file: file, line: line)
            case let (.failure(receivedError as RemoteFeedLoader.Error),
                .failure(expectedError as RemoteFeedLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expect \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1)
    }
    
    private class ClientSpy: HTTPClient {
        private(set) var messages = [(url: URL, completion: (HTTPClient.Result) -> Void)]()
        
        var loggedURLs: [URL] {
            messages.map(\.url)
        }
        
        private var completions: [(HTTPClient.Result) -> Void] {
            messages.map(\.completion)
        }
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with data: Data, at index: Int = 0) {
            complete(with: data, response: HTTPURLResponse(statusCode: 200), at: index)
        }
        
        func complete(with data: Data, response: HTTPURLResponse, at index: Int = 0) {
            completions[index](.success((data, response)))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            completions[index](.failure(error))
        }
    }
}