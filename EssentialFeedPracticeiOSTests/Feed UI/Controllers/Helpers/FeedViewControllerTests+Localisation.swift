//
//  FeedViewControllerTests+Localisation.swift
//  EssentialFeedPracticeiOSTests
//
//  Created by Tsz-Lung on 01/10/2023.
//

import Foundation
import XCTest
import EssentialFeedPracticeiOS

extension FeedViewControllerTests {
    func localised(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let table = "Feed"
        let bundle = Bundle(for: FeedViewController.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localised string for key: \(key) in table \(table)", file: file, line: line)
        }
        return value
    }
}
