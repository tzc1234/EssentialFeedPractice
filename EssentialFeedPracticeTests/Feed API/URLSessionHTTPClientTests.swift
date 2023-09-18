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
    
    struct UnexpectedRepresentationError: Error {}
    
    func get(from url: URL, completion: @escaping (Result<(Data, HTTPURLResponse), Error>) -> Void) {
        session.dataTask(with: url) { data, response, error in
            if let data, let httpResponse = response as? HTTPURLResponse {
                completion(.success((data, httpResponse)))
            } else if let error {
                completion(.failure(error))
            } else {
                completion(.failure(UnexpectedRepresentationError()))
            }
        }.resume()
    }
}

final class URLSessionHTTPClientTests: XCTestCase {
    override func setUp() {
        super.setUp()
        
        URLProtocolStub.reset()
    }
    
    override func tearDown() {
        super.tearDown()
        
        URLProtocolStub.reset()
    }
    
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
        XCTAssertNotNil(errorFor((nil, nil, nil)))
        XCTAssertNotNil(errorFor((anyData(), nil, nil)))
        XCTAssertNotNil(errorFor((nil, nil, anyNSError())))
        XCTAssertNotNil(errorFor((nil, nonHTTPResponse(), nil)))
        XCTAssertNotNil(errorFor((anyData(), nil, anyNSError())))
        XCTAssertNotNil(errorFor((nil, nonHTTPResponse(), anyNSError())))
        XCTAssertNotNil(errorFor((nil, anyHTTPResponse(), anyNSError())))
        XCTAssertNotNil(errorFor((anyData(), nonHTTPResponse(), anyNSError())))
        XCTAssertNotNil(errorFor((anyData(), anyHTTPResponse(), anyNSError())))
    }
    
    func test_get_succeedsOnHTTPRequestWithData() {
        let sut = makeSUT()
        let data = anyData()
        let httpResponse = anyHTTPResponse()
        URLProtocolStub.stub(data: data, response: httpResponse, error: nil)
        
        let exp = expectation(description: "Wait for completion")
        sut.get(from: anyURL()) { result in
            switch result {
            case let .success((receivedData, receivedResponse)):
                XCTAssertEqual(receivedData, data)
                
                XCTAssertEqual(receivedResponse.url, httpResponse.url)
                XCTAssertEqual(receivedResponse.statusCode, httpResponse.statusCode)
            case let .failure(error):
                XCTFail("Expect a success, got \(error) instead")
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
    
    private func errorFor(_ value: (data: Data?, response: URLResponse?, error: Error?),
                          file: StaticString = #filePath, line: UInt = #line) -> Error? {
        let sut = makeSUT(file: file, line: line)
        URLProtocolStub.stub(data: value.data, response: value.response, error: value.error)
        
        var receivedError: Error?
        let exp = expectation(description: "Wait for completion")
        sut.get(from: anyURL()) { result in
            switch result {
            case .success:
                XCTFail("Expect a failure, got \(result) instead", file: file, line: line)
            case let .failure(error):
                receivedError = error
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
        return receivedError
    }
    
    private func nonHTTPResponse() -> URLResponse {
        URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func anyHTTPResponse() -> HTTPURLResponse {
        HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    
    private func anyData() -> Data {
        Data("any data".utf8)
    }
    
    private class URLProtocolStub: URLProtocol {
        struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static var observer: ((URLRequest) -> Void)?
        static var stub: Stub?
        
        static func reset() {
            observer = nil
            stub = nil
        }
        
        static func stub(data: Data?, response: URLResponse?, error: Error?) {
            stub = Stub(data: data, response: response, error: error)
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            request
        }
        
        override func startLoading() {
            let stub = Self.stub
            
            if let data = stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
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
