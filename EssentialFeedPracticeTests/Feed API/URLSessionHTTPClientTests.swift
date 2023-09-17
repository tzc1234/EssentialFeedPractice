//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedPracticeTests
//
//  Created by Tsz-Lung on 17/09/2023.
//

import XCTest

class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(from url: URL) {
        session.dataTask(with: url) { _,_,_ in
            
        }.resume()
    }
}

final class URLSessionHTTPClientTests: XCTestCase {
    func test_get_requestsFromURL() {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        let sut = URLSessionHTTPClient(session: session)
        let url = anyURL()
        
        let exp = expectation(description: "Wait for completion")
        URLProtocolStub.observer = { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        sut.get(from: url)
        
        wait(for: [exp], timeout: 1)
    }
    
    // MARK: - Helpers
    
    private class URLProtocolStub: URLProtocol {
        static var observer: ((URLRequest) -> Void)?
        
        override class func canInit(with request: URLRequest) -> Bool {
            true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            request
        }
        
        override func startLoading() {
            client?.urlProtocolDidFinishLoading(self)
            
            Self.observer?(request)
        }
        
        override func stopLoading() {}
    }
}
