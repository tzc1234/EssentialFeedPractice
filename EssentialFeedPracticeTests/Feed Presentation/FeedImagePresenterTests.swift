//
//  FeedImagePresenterTests.swift
//  EssentialFeedPracticeTests
//
//  Created by Tsz-Lung on 04/10/2023.
//

import XCTest

final class FeedImagePresenter {
    private let view: Any
    
    init(view: Any) {
        self.view = view
    }
}

final class FeedImagePresenterTests: XCTestCase {
    func test_init_doesNotMessageView() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: FeedImagePresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter(view: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }
    
    private class ViewSpy {
        private(set) var messages = [Any]()
    }
}
