//
//  FeedStoreSpy.swift
//  EssentialFeedPracticeTests
//
//  Created by Tsz-Lung on 11/09/2023.
//

import Foundation
import EssentialFeedPractice

class FeedStoreSpy: FeedStore {
    typealias RetrieveResult = Result<([LocalFeedImage], Date), Error>
    
    private(set) var messages = [Message]()
    private var deletionCompletions = [(Result<Void, Error>) -> Void]()
    private var insertionCompletions = [(Result<Void, Error>) -> Void]()
    private var retrievalCompletions = [(RetrieveResult) -> Void]()
    
    enum Message: Equatable {
        case deletion
        case insertion([LocalFeedImage], Date)
        case retrieval
    }
    
    func deleteCachedFeed(completion: @escaping (Result<Void, Error>) -> Void) {
        messages.append(.deletion)
        deletionCompletions.append(completion)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](.failure(error))
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](.success(()))
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping (Result<Void, Error>) -> Void) {
        messages.append(.insertion(feed, timestamp))
        insertionCompletions.append(completion)
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionCompletions[index](.failure(error))
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionCompletions[index](.success(()))
    }
    
    func retrieve(completion: @escaping (RetrieveResult) -> Void) {
        messages.append(.retrieval)
        retrievalCompletions.append(completion)
    }
    
    func completeRetrieval(with error: Error, at index: Int = 0) {
        retrievalCompletions[index](.failure(error))
    }
    
    func completeRetrievalWithEmptyCache(at index: Int = 0) {
        completeRetrieval(with: [], timestamp: .now, at: index)
    }
    
    func completeRetrieval(with feed: [LocalFeedImage], timestamp: Date, at index: Int = 0) {
        retrievalCompletions[index](.success((feed, timestamp)))
    }
}
