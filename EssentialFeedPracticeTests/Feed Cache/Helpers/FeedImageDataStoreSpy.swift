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
    private var retrieveCompletions = [(FeedImageDataStore.Result) -> Void]()
    
    func retrieveData(for url: URL, completion: @escaping (FeedImageDataStore.Result) -> Void) {
        messages.append(.retrieveData(for: url))
        retrieveCompletions.append(completion)
    }
    
    func complete(with error: Error, at index: Int = 0) {
        retrieveCompletions[index](.failure(error))
    }
    
    func complete(with data: Data?, at index: Int = 0) {
        retrieveCompletions[index](.success(data))
    }
    
    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
        messages.append(.insert(data: data, for: url))
    }
}
