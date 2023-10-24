//
//  RemoteImageCommentsLoader.swift
//  EssentialFeedPractice
//
//  Created by Tsz-Lung on 23/10/2023.
//

import Foundation

public typealias RemoteImageCommentsLoader = RemoteLoader<[ImageComment]>

public extension RemoteImageCommentsLoader {
    convenience init(client: HTTPClient, url: URL) {
        self.init(client: client, url: url, mapper: ImageCommentsMapper.map)
    }
}
