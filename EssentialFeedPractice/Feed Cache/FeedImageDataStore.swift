//
//  FeedImageDataStore.swift
//  EssentialFeedPractice
//
//  Created by Tsz-Lung on 08/10/2023.
//

import Foundation

public protocol FeedImageDataStore {
    func insert(_ data: Data, for url: URL) throws
    func retrieveData(for url: URL) throws -> Data?
}
