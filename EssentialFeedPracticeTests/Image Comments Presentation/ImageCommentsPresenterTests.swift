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
    
    func test_map_createsViewModel() {
        let now = Date()
        let calendar = Calendar(identifier: .gregorian)
        let locale = Locale(identifier: "en_US_POSIX")
        let comments = [
            makeComment(
                message: "a message",
                createdAt: (now.adding(minutes: -5), "5 minutes ago"),
                username: "a username"),
            makeComment(
                message: "another message",
                createdAt: (now.adding(days: -1), "1 day ago"),
                username: "another username")
        ]
        
        let viewModel = ImageCommentsPresenter.map(
            comments.map(\.model),
            currentDate: now,
            calendar: calendar,
            locale: locale
        )
        
        XCTAssertEqual(viewModel.comments, comments.map(\.viewModel))
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
    
    private func makeComment(message: String,
                             createdAt: (date: Date, formatted: String),
                             username: String) -> (model: ImageComment, viewModel: ImageCommentViewModel) {
        let model = ImageComment(id: UUID(), message: message, createdAt: createdAt.date, username: username)
        let viewModel = ImageCommentViewModel(message: message, date: createdAt.formatted, username: username)
        return (model, viewModel)
    }
}
