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

struct FeedImageLoadingViewModel {
    let isLoading: Bool
}

protocol FeedImageView {
    associatedtype Image
    
    func display(_ viewModel: FeedImageViewModel<Image>)
}

protocol FeedImageLoadingView {
    func display(_ viewModel: FeedImageLoadingViewModel)
}

final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    private let view: View
    private let loadingView: FeedImageLoadingView
    
    init(view: View, loadingView: FeedImageLoadingView) {
        self.view = view
        self.loadingView = loadingView
    }
    
    func didStartLoadingImageData(for model: FeedImage) {
        loadingView.display(FeedImageLoadingViewModel(isLoading: true))
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
        
        XCTAssertFalse(view.isLoading)
        XCTAssertTrue(view.messages.isEmpty)
    }
    
    func test_didStartLoadingImageData_displaysImageAndStartLoading() {
        let (sut, view) = makeSUT()
        let image = uniqueFeedImage()
        
        sut.didStartLoadingImageData(for: image)
        
        XCTAssertTrue(view.isLoading)
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
        let sut = FeedImagePresenter(view: view, loadingView: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }
    
    private class ViewSpy: FeedImageView, FeedImageLoadingView {
        private(set) var messages = [FeedImageViewModel<Any>]()
        private(set) var isLoading = false
        
        func display(_ viewModel: FeedImageViewModel<Any>) {
            messages.append(viewModel)
        }
        
        func display(_ viewModel: FeedImageLoadingViewModel) {
            isLoading = viewModel.isLoading
        }
    }
}
