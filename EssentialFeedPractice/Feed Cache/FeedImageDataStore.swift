//
//  FeedImageDataStore.swift
//  EssentialFeedPractice
//
//  Created by Tsz-Lung on 08/10/2023.
//

import Foundation

public protocol FeedImageDataStore {
    typealias Result = Swift.Result<Data?, Error>
    
    func retrieveData(for url: URL, completion: @escaping (Result) -> Void)
}
