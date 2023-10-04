//
//  FeedImagePresenterTests.swift
//  EssentialFeedPracticeTests
//
//  Created by Tsz-Lung on 04/10/2023.
//

import XCTest
import EssentialFeedPractice

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
    
    func test_didFinishLoadingImageData_displaysRetryOnFailedImageTransformationAndStopLoading() {
        let (sut, view) = makeSUT(imageTransformer: fail)
        let image = uniqueFeedImage()
        
        sut.didFinishLoadingImageData(with: Data(), for: image)
        
        XCTAssertFalse(view.isLoading)
        XCTAssertEqual(view.messages.count, 1)
        let message = view.messages.first
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertNil(message?.image)
        XCTAssertEqual(message?.shouldRetry, true)
    }
    
    func test_didFinishLoadingImageData_displaysImageOnSuccessfulTransformationAndStopLoading() {
        let transformedData = AnyImage()
        let (sut, view) = makeSUT(imageTransformer: { _ in transformedData })
        let image = uniqueFeedImage()
        
        sut.didFinishLoadingImageData(with: Data(), for: image)
        
        XCTAssertFalse(view.isLoading)
        XCTAssertEqual(view.messages.count, 1)
        let message = view.messages.first
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertEqual(message?.image, transformedData)
        XCTAssertEqual(message?.shouldRetry, false)
    }
    
    func test_didFinishLoadingImageData_displaysRetryAndStopLoading() {
        let (sut, view) = makeSUT()
        let image = uniqueFeedImage()
        
        sut.didFinishLoadingImageData(with: anyNSError(), for: image)
        
        XCTAssertFalse(view.isLoading)
        XCTAssertEqual(view.messages.count, 1)
        let message = view.messages.first
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertNil(message?.image)
        XCTAssertEqual(message?.shouldRetry, true)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(imageTransformer: @escaping (Data) -> AnyImage? = { _ in nil },
                         file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: FeedImagePresenter<ViewSpy, AnyImage>, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter(view: view, loadingView: view, imageTransformer: imageTransformer)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }
    
    private var fail: (Data) -> AnyImage? {
        return { _ in nil }
    }
    
    private struct AnyImage: Equatable {}
    
    private class ViewSpy: FeedImageView, FeedImageLoadingView {
        private(set) var messages = [FeedImageViewModel<AnyImage>]()
        private(set) var isLoading = false
        
        func display(_ viewModel: FeedImageViewModel<AnyImage>) {
            messages.append(viewModel)
        }
        
        func display(_ viewModel: FeedImageLoadingViewModel) {
            isLoading = viewModel.isLoading
        }
    }
}
