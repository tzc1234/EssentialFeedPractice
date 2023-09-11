//
//  FeedStoreSpy.swift
//  EssentialFeedPracticeTests
//
//  Created by Tsz-Lung on 11/09/2023.
//

import Foundation
import EssentialFeedPractice

class FeedStoreSpy: FeedStore {
    private(set) var messages = [Message]()
    private var deletionCompletions = [(Result<Void, Error>) -> Void]()
    private var insertionCompletions = [(Result<Void, Error>) -> Void]()
    
    enum Message: Equatable {
        case deletion
        case insertion([LocalFeedImage], Date)
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
}