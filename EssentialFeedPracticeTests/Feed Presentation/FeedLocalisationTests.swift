//
//  FeedLocalisationTests.swift
//  EssentialFeedPracticeiOSTests
//
//  Created by Tsz-Lung on 01/10/2023.
//

import XCTest
@testable import EssentialFeedPractice

final class FeedLocalisationTests: XCTestCase {
    func test_localisedStrings_haveKeysAndValuesForAllSupportedLocalisations() {
        let table = "Feed"
        let bundle = Bundle(for: FeedPresenter.self)
        assertLocalisedKeyAndValuesExist(in: bundle, table)
    }
}
