//
//  FeedErrorViewModel.swift
//  EssentialFeedPracticeiOS
//
//  Created by Tsz-Lung on 03/10/2023.
//

import Foundation

struct FeedErrorViewModel {
    let message: String?
    
    static var noError: FeedErrorViewModel {
        FeedErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> FeedErrorViewModel {
        FeedErrorViewModel(message: message)
    }
}
