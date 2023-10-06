//
//  LoadFeedImageDataFromRemoteUseCaseTests.swift
//  EssentialFeedPracticeTests
//
//  Created by Tsz-Lung on 06/10/2023.
//

import XCTest
import EssentialFeedPractice

final class RemoteFeedImageDataLoader {
    private let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func loadImageData(for url: URL) {
        client.get(from: url) { _ in
            
        }
    }
}

final class LoadFeedImageDataFromRemoteUseCaseTests: XCTestCase {
    func test_init_doesNotRequestFromClientUponCreation() {
        let client = HTTPClientSpy()
        _ = RemoteFeedImageDataLoader(client: client)
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_loadImageData_requestsDataFromURL() {
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: client)
        let url = URL(string: "https://a-given-url.com")!
        
        sut.loadImageData(for: url)
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    // MARK: - Helpers
    
    private class HTTPClientSpy: HTTPClient {
        private(set) var requestedURLs = [URL]()
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
            requestedURLs.append(url)
        }
    }
}
