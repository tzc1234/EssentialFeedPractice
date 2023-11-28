//
//  FeedImageDataStore.swift
//  EssentialFeedPractice
//
//  Created by Tsz-Lung on 08/10/2023.
//

import Foundation

public protocol FeedImageDataStore {
    typealias InsertionResult = Result<Void, Error>
    typealias RetrievalResult = Result<Data?, Error>
    
    func insert(_ data: Data, for url: URL) throws
    func retrieveData(for url: URL) throws -> Data?
    
    @available(*, deprecated)
    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void)
    
    @available(*, deprecated)
    func retrieveData(for url: URL, completion: @escaping (RetrievalResult) -> Void)
}

public extension FeedImageDataStore {
    func insert(_ data: Data, for url: URL) throws {
        let group = DispatchGroup()
        group.enter()
        var result: InsertionResult!
        insert(data, for: url) {
            result = $0
            group.leave()
        }
        group.wait()
        try result.get()
    }
    
    func retrieveData(for url: URL) throws -> Data? {
        let group = DispatchGroup()
        group.enter()
        var result: RetrievalResult!
        retrieveData(for: url) {
            result = $0
            group.leave()
        }
        group.wait()
        return try result.get()
    }
    
    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {}
    func retrieveData(for url: URL, completion: @escaping (RetrievalResult) -> Void) {}
}
