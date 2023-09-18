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
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        client.get(from: url) { _ in }
        completion(.failure(Error.connectivity))
    }
}

final class LoadFeedFromRemoteUseCaseTests: XCTestCase {
    func test_init_doesNotRequestFromClientUponCreation() {
        let (_, client) = makeSUT()
        
        XCTAssertEqual(client.requestCallCount, 0)
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
        private(set) var completions = [(HTTPClient.Result) -> Void]()
        private(set) var loggedURLs = [URL]()
        
        var requestCallCount: Int {
            loggedURLs.count
        }
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
            loggedURLs.append(url)
            completions.append(completion)
        }
        
        func complete(with error: Error, at index: Int = 0) {
            completions[index](.failure(error))
        }
    }
}
