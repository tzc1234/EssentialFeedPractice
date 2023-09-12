//
//  FeedCachePolicy.swift
//  EssentialFeedPractice
//
//  Created by Tsz-Lung on 11/09/2023.
//

import Foundation

enum FeedCachePolicy {
    private static let calendar = Calendar(identifier: .gregorian)
    private static let maxCacheAgeInDays = 7
    
    static func validate(_ timestamp: Date, against date: Date) -> Bool {
        guard let expirationDate = calendar.date(byAdding: .day, value: -maxCacheAgeInDays, to: date) else {
            return false
        }
        
        return timestamp > expirationDate
    }
}
