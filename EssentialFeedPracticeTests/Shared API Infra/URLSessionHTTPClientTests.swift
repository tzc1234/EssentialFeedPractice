//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedPracticeTests
//
//  Created by Tsz-Lung on 17/09/2023.
//

import XCTest
import EssentialFeedPractice

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
        URLProtocolStub.observe { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        sut.get(from: url) { _ in }
        
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
        let data = anyData()
        let httpResponse = anyHTTPResponse()
        
        let received = valueFor((data: data, response: httpResponse, error: nil))
        
        XCTAssertEqual(received?.data, data)
        XCTAssertEqual(received?.response.url, httpResponse.url)
        XCTAssertEqual(received?.response.statusCode, httpResponse.statusCode)
    }
    
    func test_get_succeedsOnHTTPRequestWithNilData() {
        let httpResponse = anyHTTPResponse()
        
        let received = valueFor((data: nil, response: httpResponse, error: nil))
        
        let emptyData = Data()
        XCTAssertEqual(received?.data, emptyData)
        XCTAssertEqual(received?.response.url, httpResponse.url)
        XCTAssertEqual(received?.response.statusCode, httpResponse.statusCode)
    }
    
    func test_cancelGetFromURLTask_cancelsURLRequest() {
        let exp = expectation(description: "Wait for request")
        URLProtocolStub.observe { _ in exp.fulfill() }
        
        let receivedError = errorFor(taskHandler: { $0.cancel() }) as? NSError
        wait(for: [exp], timeout: 5)
        
        XCTAssertEqual(receivedError?.code, URLError.cancelled.rawValue)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        let sut = URLSessionHTTPClient(session: session)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func valueFor(_ value: (data: Data?, response: URLResponse?, error: Error?),
                          taskHandler: (HTTPClientTask) -> Void = { _ in },
                          file: StaticString = #filePath,
                          line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
        switch resultFor(value, taskHandler: taskHandler, file: file, line: line) {
        case let .success(value):
           return value
        case let .failure(error):
            XCTFail("Expect a success, got \(error) instead", file: file, line: line)
            return nil
        }
    }
    
    private func errorFor(_ value: (data: Data?, response: URLResponse?, error: Error?)? = nil,
                          taskHandler: (HTTPClientTask) -> Void = { _ in },
                          file: StaticString = #filePath,
                          line: UInt = #line) -> Error? {
        switch resultFor(value, taskHandler: taskHandler, file: file, line: line) {
        case let .success(value):
            XCTFail("Expect a failure, got \(value) instead", file: file, line: line)
            return nil
        case let .failure(error):
            return error
        }
    }
    
    private func resultFor(_ value: (data: Data?, response: URLResponse?, error: Error?)? = nil,
                           taskHandler: (HTTPClientTask) -> Void = { _ in },
                           file: StaticString = #filePath,
                           line: UInt = #line) -> HTTPClient.Result {
        let sut = makeSUT(file: file, line: line)
        value.map { URLProtocolStub.stub(data: $0, response: $1, error: $2) }
        
        var receivedResult: HTTPClient.Result?
        let exp = expectation(description: "Wait for completion")
        taskHandler(sut.get(from: anyURL()) { result in
            receivedResult = result
            exp.fulfill()
        })
        wait(for: [exp], timeout: 5)
        return receivedResult!
    }
    
    private func nonHTTPResponse() -> URLResponse {
        URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func anyHTTPResponse() -> HTTPURLResponse {
        HTTPURLResponse(statusCode: 200)
    }
}
