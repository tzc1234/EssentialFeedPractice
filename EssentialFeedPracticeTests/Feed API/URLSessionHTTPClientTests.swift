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
    
    func get(from url: URL, completion: @escaping (Result<Any, Error>) -> Void) {
        session.dataTask(with: url) { _,_, error in
            if let error {
                completion(.failure(error))
            }
        }.resume()
    }
}

final class URLSessionHTTPClientTests: XCTestCase {
    func test_get_requestsFromURL() {
        let sut = makeSUT()
        let url = anyURL()
        
        let exp = expectation(description: "Wait for completion")
        URLProtocolStub.observer = { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        sut.get(from: url) { _ in}
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_get_failsOnRequestError() {
        let sut = makeSUT()
        URLProtocolStub.stub(error: anyNSError())
        
        let exp = expectation(description: "Wait for completion")
        sut.get(from: anyURL()) { result in
            switch result {
            case .success:
                XCTFail("Expect a failure")
            case .failure:
                break
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> URLSessionHTTPClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        let sut = URLSessionHTTPClient(session: session)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private class URLProtocolStub: URLProtocol {
        struct Stub {
            let error: Error?
        }
        
        static var observer: ((URLRequest) -> Void)?
        static var stub: Stub?
        
        static func stub(error: Error) {
            stub = .init(error: error)
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            request
        }
        
        override func startLoading() {
            let stub = Self.stub
            
            if let error = stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            } else {
                client?.urlProtocolDidFinishLoading(self)
            }

            Self.observer?(request)
        }
        
        override func stopLoading() {}
    }
}
