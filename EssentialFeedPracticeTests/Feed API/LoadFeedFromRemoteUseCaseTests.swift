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
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        client.get(from: url) { _ in }
    }
}

final class LoadFeedFromRemoteUseCaseTests: XCTestCase {
    func test_init_doesNotRequestFromClientUponCreation() {
        let client = ClientSpy()
        _ = RemoteFeedLoader(client: client, url: anyURL())
        
        XCTAssertEqual(client.requestCallCount, 0)
    }
    
    func test_load_requestsFromURL() {
        let client = ClientSpy()
        let url = anyURL()
        let sut = RemoteFeedLoader(client: client, url: url)
        
        sut.load { _ in }
        
        XCTAssertEqual(client.loggedURLs, [url])
    }
    
    // MARK: - Helpers
    
    private class ClientSpy: HTTPClient {
        private(set) var loggedURLs = [URL]()
        
        var requestCallCount: Int {
            loggedURLs.count
        }
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
            loggedURLs.append(url)
        }
    }
}
