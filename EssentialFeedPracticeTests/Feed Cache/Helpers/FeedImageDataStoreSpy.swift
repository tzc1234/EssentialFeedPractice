//
//  FeedImageDataStoreSpy.swift
//  EssentialFeedPracticeTests
//
//  Created by Tsz-Lung on 08/10/2023.
//

import Foundation
import EssentialFeedPractice

final class FeedImageDataStoreSpy: FeedImageDataStore {
    enum Message: Equatable {
        case retrieveData(for: URL)
        case insert(data: Data, for: URL)
    }
    
    private(set) var messages = [Message]()
    
    private var insertionResult: InsertionResult?
    
    func insert(_ data: Data, for url: URL) throws {
        messages.append(.insert(data: data, for: url))
        try insertionResult?.get()
    }
    
    func completeInsertion(with error: Error) {
        insertionResult = .failure(error)
    }
    
    func completeInsertionSuccessfully() {
        insertionResult = .success(())
    }
    
    private var retrievalResult: RetrievalResult?
    
    func retrieveData(for url: URL) throws -> Data? {
        messages.append(.retrieveData(for: url))
        return try retrievalResult?.get()
    }
    
    func completeRetrieval(with error: Error) {
        retrievalResult = .failure(error)
    }
    
    func completeRetrieval(with data: Data?) {
        retrievalResult = .success(data)
    }
}
