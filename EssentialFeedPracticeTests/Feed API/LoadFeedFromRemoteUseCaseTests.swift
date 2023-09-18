//
//  LoadFeedFromRemoteUseCaseTests.swift
//  EssentialFeedPracticeTests
//
//  Created by Tsz-Lung on 18/09/2023.
//

import XCTest
import EssentialFeedPractice

class RemoteFeedLoader: FeedLoader {
    private let client: HTTPClient
    private let url: URL
    
    init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case .success((_, _)):
                completion(.failure(Error.invalidData))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
        
    }
}

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
        
        let exp = expectation(description: "Wait for completion")
        sut.load { result in
            switch result {
            case .success:
                XCTFail("Expect an error, got \(result) instead")
            case let .failure(error):
                XCTAssertEqual(error as? RemoteFeedLoader.Error, .connectivity)
            }
            exp.fulfill()
        }
        client.complete(with: anyNSError())
        wait(for: [exp], timeout: 1)
    }
    
    func test_load_deliversInvalidDataErrorWhenReceivedInvalidDataFromClient() {
        let (sut, client) = makeSUT()
        let invalidData = Data("invalid data".utf8)
        
        let exp = expectation(description: "Wait for completion")
        sut.load { result in
            switch result {
            case .success:
                XCTFail("Expect an error, got \(result) instead")
            case let .failure(error):
                XCTAssertEqual(error as? RemoteFeedLoader.Error, .invalidData)
            }
            exp.fulfill()
        }
        client.complete(with: invalidData)
        wait(for: [exp], timeout: 1)
    }
    
    func test_load_deliversInvalidDataErrorWhenNon200ResponseFromClient() {
        let (sut, client) = makeSUT()
        let non200Response = HTTPURLResponse(url: anyURL(), statusCode: 100, httpVersion: nil, headerFields: nil)!
        
        let exp = expectation(description: "Wait for completion")
        sut.load { result in
            switch result {
            case .success:
                XCTFail("Expect an error, got \(result) instead")
            case let .failure(error):
                XCTAssertEqual(error as? RemoteFeedLoader.Error, .invalidData)
            }
            exp.fulfill()
        }
        client.complete(with: anyData(), response: non200Response)
        wait(for: [exp], timeout: 1)
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
            let response = HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
            complete(with: data, response: response, at: index)
        }
        
        func complete(with data: Data, response: HTTPURLResponse, at index: Int = 0) {
            completions[index](.success((data, response)))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            completions[index](.failure(error))
        }
    }
}
