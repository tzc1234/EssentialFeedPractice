//
//  Publisher+Logging.swift
//  EssentialApp
//
//  Created by Tsz-Lung on 29/11/2023.
//

import Combine
import OSLog
import UIKit

extension Publisher {
    func logCacheMisses(url: URL, logger: Logger) -> AnyPublisher<Output, Failure> {
        handleEvents(receiveCompletion: { result in
            if case .failure = result {
                logger.trace("Cache miss for url: \(url)")
            }
        })
        .eraseToAnyPublisher()
    }
    
    func logError(url: URL, logger: Logger) ->  AnyPublisher<Output, Failure> {
        handleEvents(receiveCompletion: { result in
            if case let .failure(error) = result {
                logger.trace("Failed to load url: \(url) with error: \(error)")
            }
        })
        .eraseToAnyPublisher()
    }
    
    func logElapsedTime(url: URL, logger: Logger) -> AnyPublisher<Output, Failure> {
        var startTime = CACurrentMediaTime()
        
        return handleEvents(receiveSubscription: { _ in
            logger.trace("Started loading url: \(url)")
            startTime = CACurrentMediaTime()
        }, receiveCompletion: { _ in
            let elapsed = CACurrentMediaTime() - startTime
            logger.trace("Finished loading url: \(url) in \(elapsed) seconds")
        })
        .eraseToAnyPublisher()
    }
}
