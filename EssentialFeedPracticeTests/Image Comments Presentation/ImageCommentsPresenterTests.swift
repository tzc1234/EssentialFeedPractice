//
//  ImageCommentsPresenterTests.swift
//  EssentialFeedPracticeTests
//
//  Created by Tsz-Lung on 26/10/2023.
//

import XCTest
import EssentialFeedPractice

final class ImageCommentsPresenterTests: XCTestCase {
    func test_title_isLocalised() {
        XCTAssertEqual(ImageCommentsPresenter.title, localised("IMAGE_COMMENTS_VIEW_TITLE"))
    }
    
    // MARK: - Helpers
    
    private func localised(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let table = "ImageComments"
        let bundle = Bundle(for: ImageCommentsPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localised string for key: \(key) in table \(table)", file: file, line: line)
        }
        return value
    }
}
