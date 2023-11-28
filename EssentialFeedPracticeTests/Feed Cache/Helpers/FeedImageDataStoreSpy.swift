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
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionResult = .failure(error)
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionResult = .success(())
    }
    
    private var retrievalCompletions = [(RetrievalResult) -> Void]()
    
    func retrieveData(for url: URL, completion: @escaping (RetrievalResult) -> Void) {
        messages.append(.retrieveData(for: url))
        retrievalCompletions.append(completion)
    }
    
    func completeRetrieval(with error: Error, at index: Int = 0) {
        retrievalCompletions[index](.failure(error))
    }
    
    func completeRetrieval(with data: Data?, at index: Int = 0) {
        retrievalCompletions[index](.success(data))
    }
}
