//
//  FeedCacheHelpers.swift
//  EssentialFeedPracticeTests
//
//  Created by Tsz-Lung on 11/09/2023.
//

import Foundation
import EssentialFeedPractice

func anyNSError() -> NSError {
    NSError(domain: "any", code: 0)
}

func anyURL() -> URL {
    URL(string: "https://any-url.com")!
}

func uniqueFeed() -> (models: [FeedImage], locals: [LocalFeedImage]) {
    let images = [uniqueFeedImage()]
    let locals = images.map {
        LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)
    }
    return (images, locals)
}

private func uniqueFeedImage() -> FeedImage {
    .init(id: UUID(), description: "any description", location: "any location", url: anyURL())
}

func anyData() -> Data {
    Data("any data".utf8)
}
