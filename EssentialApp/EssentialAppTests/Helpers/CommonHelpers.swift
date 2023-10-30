//
//  CommonHelpers.swift
//  EssentialAppTests
//
//  Created by Tsz-Lung on 11/10/2023.
//

import Foundation
import EssentialFeedPractice

func anyNSError() -> NSError {
    NSError(domain: "any", code: 0)
}

func anyData() -> Data {
    Data("any data".utf8)
}

func uniqueFeed() -> [FeedImage] {
    [
        .init(id: UUID(),
              description: "any description",
              location: "any location",
              url: anyURL())
    ]
}

func anyURL() -> URL {
    URL(string: "https://any-url.com")!
}

var loadError: String {
    LoadResourcePresenter<Any, DummyView>.loadError
}

private class DummyView: ResourceView {
    func display(_ viewModel: Any) {}
}

var feedTitle: String {
    FeedPresenter.title
}

var commentsTitle: String {
    ImageCommentsPresenter.title
}
