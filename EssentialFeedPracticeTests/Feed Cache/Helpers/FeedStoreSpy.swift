//
//  FeedStoreSpy.swift
//  EssentialFeedPracticeTests
//
//  Created by Tsz-Lung on 11/09/2023.
//

import Foundation
import EssentialFeedPractice

final class FeedStoreSpy: FeedStore {
    enum Message: Equatable {
        case deletion
        case insertion([LocalFeedImage], Date)
        case retrieval
    }
    
    private(set) var messages = [Message]()
    private var deletionCompletions = [DeleteCompletion]()
    private var insertionCompletions = [InsertCompletion]()
    private var retrievalCompletions = [RetrieveCompletion]()
    
    func deleteCachedFeed(completion: @escaping DeleteCompletion) {
        messages.append(.deletion)
        deletionCompletions.append(completion)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](.failure(error))
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](.success(()))
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertCompletion) {
        messages.append(.insertion(feed, timestamp))
        insertionCompletions.append(completion)
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionCompletions[index](.failure(error))
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionCompletions[index](.success(()))
    }
    
    func retrieve(completion: @escaping RetrieveCompletion) {
        messages.append(.retrieval)
        retrievalCompletions.append(completion)
    }
    
    func completeRetrieval(with error: Error, at index: Int = 0) {
        retrievalCompletions[index](.failure(error))
    }
    
    func completeRetrievalWithEmptyCache(at index: Int = 0) {
        retrievalCompletions[index](.success(.none))
    }
    
    func completeRetrieval(with feed: [LocalFeedImage], timestamp: Date, at index: Int = 0) {
        retrievalCompletions[index](.success((feed, timestamp)))
    }
}
