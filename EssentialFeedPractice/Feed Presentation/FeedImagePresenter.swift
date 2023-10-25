//
//  FeedImagePresenter.swift
//  EssentialFeedPractice
//
//  Created by Tsz-Lung on 04/10/2023.
//

import Foundation

public final class FeedImagePresenter {
    public static func map(_ image: FeedImage) -> FeedImageViewModel {
        FeedImageViewModel(description: image.description, location: image.location)
    }
}
