//
//  LoadFeedFromRemoteUseCaseTests.swift
//  EssentialFeedPracticeTests
//
//  Created by Tsz-Lung on 18/09/2023.
//

import XCTest
import EssentialFeedPractice

class RemoteFeedLoader: FeedLoader {
    init(client: HTTPClient) {
        
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        
    }
}

final class LoadFeedFromRemoteUseCaseTests: XCTestCase {
    func test_init_doesNotRequestFromClientUponCreation() {
        let client = ClientSpy()
        _ = RemoteFeedLoader(client: client)
        
        XCTAssertEqual(client.requestCallCount, 0)
    }
    
    // MARK: - Helpers
    
    private class ClientSpy: HTTPClient {
        private(set) var requestCallCount = 0
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
            
        }
    }
}
