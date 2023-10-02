//
//  MainQueueDispatchDecorator.swift
//  EssentialFeedPracticeiOS
//
//  Created by Tsz-Lung on 02/10/2023.
//

import Foundation
import EssentialFeedPractice

final class MainQueueDispatchDecorator: FeedLoader {
    private let decoratee: FeedLoader
    
    init(decoratee: FeedLoader) {
        self.decoratee = decoratee
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load { result in
            if Thread.isMainThread {
                completion(result)
            } else {
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        }
    }
}
