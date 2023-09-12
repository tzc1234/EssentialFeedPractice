//
//  FeedCachePolicy.swift
//  EssentialFeedPractice
//
//  Created by Tsz-Lung on 11/09/2023.
//

import Foundation

final class FeedCachePolicy {
    private static let calendar = Calendar(identifier: .gregorian)
    private static let maxCacheAgeByDays = 7
    
    static func validate(_ timestamp: Date, against date: Date) -> Bool {
        guard let expirationDate = calendar.date(byAdding: .day, value: -maxCacheAgeByDays, to: date) else {
            return false
        }
        
        return timestamp > expirationDate
    }
}
