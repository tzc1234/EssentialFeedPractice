//
//  FeedImageViewModel.swift
//  EssentialFeedPractice
//
//  Created by Tsz-Lung on 04/10/2023.
//

import Foundation

public struct FeedImageViewModel<Image> {
    public let description: String?
    public let location: String?
    public let image: Image?
    public let shouldRetry: Bool
}
