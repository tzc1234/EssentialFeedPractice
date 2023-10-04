//
//  FeedImagePresenterTests.swift
//  EssentialFeedPracticeTests
//
//  Created by Tsz-Lung on 04/10/2023.
//

import XCTest
import EssentialFeedPractice

struct FeedImageViewModel<Image> {
    let description: String?
    let location: String?
    let image: Image?
    let shouldRetry: Bool
}

protocol FeedImageView {
    associatedtype Image
    
    func display(_ viewModel: FeedImageViewModel<Image>)
}

final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    private let view: View
    
    init(view: View) {
        self.view = view
    }
    
    func didStartLoadingImageData(for model: FeedImage) {
        view.display(FeedImageViewModel<Image>(
            description: model.description,
            location: model.location,
            image: nil,
            shouldRetry: false))
    }
}

final class FeedImagePresenterTests: XCTestCase {
    func test_init_doesNotMessageView() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty)
    }
    
    func test_didStartLoadingImageData_displaysImage() {
        let (sut, view) = makeSUT()
        let image = uniqueFeedImage()
        
        sut.didStartLoadingImageData(for: image)
        
        XCTAssertEqual(view.messages.count, 1)
        let message = view.messages.first
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertNil(message?.image)
        XCTAssertEqual(message?.shouldRetry, false)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: FeedImagePresenter<ViewSpy, Any>, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter(view: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }
    
    private class ViewSpy: FeedImageView {
        private(set) var messages = [FeedImageViewModel<Any>]()
        
        func display(_ viewModel: FeedImageViewModel<Any>) {
            messages.append(viewModel)
        }
    }
}
