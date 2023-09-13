//
//  Date+TestHelpers.swift
//  EssentialFeedPracticeTests
//
//  Created by Tsz-Lung on 12/09/2023.
//

import Foundation

extension Date {
    func minusMaxCacheAgeInDays() -> Date {
        adding(days: -feedCacheMaxAgeInDays)
    }
    
    private var feedCacheMaxAgeInDays: Int { 7 }
    
    private func adding(days: Int, calendar: Calendar = Calendar(identifier: .gregorian)) -> Date {
        calendar.date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: TimeInterval) -> Date {
        self + seconds
    }
}
