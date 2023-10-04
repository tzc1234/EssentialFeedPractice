//
//  FeedPresenterTests.swift
//  EssentialFeedPracticeTests
//
//  Created by Tsz-Lung on 04/10/2023.
//

import XCTest

final class FeedPresenter {
    private let view: FeedPresenterTests.ViewSpy
    
    init(view: FeedPresenterTests.ViewSpy) {
        self.view = view
    }
}

final class FeedPresenterTests: XCTestCase {
    func test_init_doesNotMessageToView() {
        let view = ViewSpy()
        
        _ = FeedPresenter(view: view)
        
        XCTAssertTrue(view.messages.isEmpty)
    }
    
    // MARK: - Helpers
    
    class ViewSpy {
        private(set) var messages = [Any]()
    }
}
