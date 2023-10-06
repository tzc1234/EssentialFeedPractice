//
//  LoadFeedImageDataFromRemoteUseCaseTests.swift
//  EssentialFeedPracticeTests
//
//  Created by Tsz-Lung on 06/10/2023.
//

import XCTest
import EssentialFeedPractice

final class RemoteFeedImageDataLoader {
    init(client: Any) {
        
    }
}

final class LoadFeedImageDataFromRemoteUseCaseTests: XCTestCase {
    func test_init_doesNotRequestFromClientUponCreation() {
        let client = HTTPClientSpy()
        _ = RemoteFeedImageDataLoader(client: client)
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    // MARK: - Helpers
    
    private class HTTPClientSpy {
        private(set) var requestedURLs = [URL]()
    }
}
