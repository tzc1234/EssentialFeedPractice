//
//  FeedImageDataLoader.swift
//  EssentialFeedPracticeiOS
//
//  Created by Tsz-Lung on 25/09/2023.
//

import Foundation

public protocol FeedImageDataLoaderTask {
    func cancel()
}

public protocol FeedImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    
    func loadImage(from url: URL, completion: @escaping (Result) -> Void) -> FeedImageDataLoaderTask
}
