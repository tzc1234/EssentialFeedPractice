//
//  HTTPClientSpy.swift
//  EssentialFeedPracticeTests
//
//  Created by Tsz-Lung on 23/10/2023.
//

import Foundation
import EssentialFeedPractice

final class HTTPClientSpy: HTTPClient {
    private(set) var messages = [(url: URL, completion: (HTTPClient.Result) -> Void)]()
    
    var loggedURLs: [URL] {
        messages.map(\.url)
    }
    
    private struct Task: HTTPClientTask {
        func cancel() {}
    }
    
    private var completions: [(HTTPClient.Result) -> Void] {
        messages.map(\.completion)
    }
    
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        messages.append((url, completion))
        return Task()
    }
    
    func complete(with data: Data, statusCode: Int = 200, at index: Int = 0) {
        completions[index](.success((data, HTTPURLResponse(statusCode: statusCode))))
    }
    
    func complete(with error: Error, at index: Int = 0) {
        completions[index](.failure(error))
    }
}
