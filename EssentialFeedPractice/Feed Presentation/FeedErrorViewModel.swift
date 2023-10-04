//
//  FeedErrorViewModel.swift
//  EssentialFeedPractice
//
//  Created by Tsz-Lung on 04/10/2023.
//

import Foundation

public struct FeedErrorViewModel {
    public let message: String?
    
    static var noError: FeedErrorViewModel {
        FeedErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> FeedErrorViewModel {
        FeedErrorViewModel(message: message)
    }
}
