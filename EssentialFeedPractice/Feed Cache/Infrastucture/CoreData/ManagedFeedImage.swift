//
//  ManagedFeedImage.swift
//  EssentialFeedPractice
//
//  Created by Tsz-Lung on 15/09/2023.
//

import CoreData

@objc(ManagedFeedImage)
final class ManagedFeedImage: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var imageDescription: String?
    @NSManaged var location: String?
    @NSManaged var url: URL
    @NSManaged var data: Data?
    @NSManaged var cache: ManagedCache
}

extension ManagedFeedImage {
    var local: LocalFeedImage {
        .init(id: id, description: imageDescription, location: location, url: url)
    }
}
