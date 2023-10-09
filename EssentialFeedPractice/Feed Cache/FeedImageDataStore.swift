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
    
    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void)
    func retrieveData(for url: URL, completion: @escaping (RetrievalResult) -> Void)
}
