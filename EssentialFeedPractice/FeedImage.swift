//
//  FeedImage.swift
//  EssentialFeedPractice
//
//  Created by Tsz-Lung on 10/09/2023.
//

import Foundation

public struct FeedImage {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let imageURL: URL
    
    public init(id: UUID, description: String?, location: String?, imageURL: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.imageURL = imageURL
    }
}
