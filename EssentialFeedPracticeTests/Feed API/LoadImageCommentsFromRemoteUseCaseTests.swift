//
//  LoadImageCommentsFromRemoteUseCaseTests.swift
//  EssentialFeedPracticeTests
//
//  Created by Tsz-Lung on 23/10/2023.
//

import XCTest
import EssentialFeedPractice

final class LoadImageCommentsFromRemoteUseCaseTests: XCTestCase {
    func test_init_doesNotRequestFromClientUponCreation() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.loggedURLs.isEmpty)
    }
    
    func test_load_requestsFromURL() {
        let url = URL(string: "https://a-url.com")!
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
    
    func test_load_deliversInvalidDataErrorWhenNon2xxResponseFromClient() {
        let (sut, client) = makeSUT()
        let simple = [100, 199, 300, 400, 500]
        
        simple.enumerated().forEach { index, statusCode in
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                client.complete(with: anyData(), statusCode: statusCode, at: index)
            })
        }
    }
    
    func test_load_deliversInvalidDataErrorOn2xxHTTPResponse() {
        let (sut, client) = makeSUT()
        let simple = [200, 201, 250, 280, 299]
        
        simple.enumerated().forEach { index, statusCode in
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                let invalidData = Data("invalid data".utf8)
                client.complete(with: invalidData, statusCode: statusCode, at: index)
            })
        }
    }
    
    func test_load_deliversEmptyFeedOn2xxResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()
        let emptyFeed = [ImageComment]()
        let simple = [200, 201, 250, 280, 299]
        
        simple.enumerated().forEach { index, statusCode in
            expect(sut, toCompleteWith: .success(emptyFeed), when: {
                let emptyItemsData = makeJSONData([])
                client.complete(with: emptyItemsData, statusCode: statusCode, at: index)
            })
        }
    }
    
    func test_load_deliversOneFeedImageOn2xxResponseWithOneItem() {
        let (sut, client) = makeSUT()
        let items = [
            makeItem(
                message: "a message",
                createdAt: (Date(timeIntervalSince1970: 1598627222), "2020-08-28T15:07:02+00:00"),
                username: "a username"
            )
        ]
        let imageComments = items.map(\.model)
        let simple = [200, 201, 250, 280, 299]
        
        simple.enumerated().forEach { index, statusCode in
            expect(sut, toCompleteWith: .success(imageComments), when: {
                let oneItemData = makeJSONData(items.map(\.json))
                client.complete(with: oneItemData, statusCode: statusCode, at: index)
            })
        }
    }
    
    func test_load_deliversFeedOn2xxResponseWithMultipleItemsData() {
        let (sut, client) = makeSUT()
        let items = [
            makeItem(
                message: "a message",
                createdAt: (Date(timeIntervalSince1970: 1598627222), "2020-08-28T15:07:02+00:00"),
                username: "a username"
            ),
            makeItem(
                message: "another message",
                createdAt: (Date(timeIntervalSince1970: 1577881882), "2020-01-01T12:31:22+00:00"),
                username: "another username"
            )
        ]
        let imageComments = items.map(\.model)
        let simple = [200, 201, 250, 280, 299]
        
        simple.enumerated().forEach { index, statusCode in
            expect(sut, toCompleteWith: .success(imageComments), when: {
                let itemsData = makeJSONData(items.map(\.json))
                client.complete(with: itemsData, statusCode: statusCode, at: index)
            })
        }
    }
    
    func test_load_doesNotDeliverFeedAfterSUTInstanceIsDeallocated() {
        let client = ClientSpy()
        var sut: RemoteImageCommentsLoader? = RemoteImageCommentsLoader(client: client, url: anyURL())
        
        var completionCount = 0
        sut?.load { _ in completionCount += 1 }
        sut = nil
        client.complete(with: anyData())
        
        XCTAssertEqual(completionCount, 0)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL? = nil,
                         file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: RemoteImageCommentsLoader, client: ClientSpy) {
        let client = ClientSpy()
        let sut = RemoteImageCommentsLoader(client: client, url: url ?? anyURL())
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, client)
    }
    
    private func failure(_ error: RemoteImageCommentsLoader.Error) -> RemoteImageCommentsLoader.Result {
        .failure(error)
    }
    
    private func makeItem(id: UUID = UUID(),
                          message: String,
                          createdAt: (date: Date, iso8601String: String),
                          username: String) -> (model: ImageComment, json: [String: Any]) {
        let model = ImageComment(id: id, message: message, createdAt: createdAt.date, username: username)
        let json: [String: Any] = [
            "id": id.uuidString,
            "message": message,
            "created_at": createdAt.iso8601String,
            "author": [
                "username": username
            ]
        ]
        return (model, json)
    }
    
    private func makeJSONData(_ items: [[String: Any]]) -> Data {
        let json: [String: Any] = ["items": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func expect(_ sut: RemoteImageCommentsLoader,
                        toCompleteWith expectedResult: RemoteImageCommentsLoader.Result,
                        when action: () -> Void,
                        file: StaticString = #filePath,
                        line: UInt = #line) {
        let exp = expectation(description: "Wait for completion")
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedComments), .success(expectedFeed)):
                XCTAssertEqual(receivedComments, expectedFeed, file: file, line: line)
            case let (.failure(receivedError as RemoteImageCommentsLoader.Error),
                .failure(expectedError as RemoteImageCommentsLoader.Error)):
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
        
        private struct Task: HTTPClientTask {
            func cancel() {}
        }
        
        private var completions: [(HTTPClient.Result) -> Void] {
            messages.map(\.completion)
        }
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
            messages.append((url, completion))
            return Task()
        }
        
        func complete(with data: Data, statusCode: Int = 200, at index: Int = 0) {
            completions[index](.success((data, HTTPURLResponse(statusCode: statusCode))))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            completions[index](.failure(error))
        }
    }
}
