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
    private let imageTransformer: (Data) -> Image?
    
    init(view: View, loadingView: FeedImageLoadingView, imageTransformer: @escaping (Data) -> Image?) {
        self.view = view
        self.loadingView = loadingView
        self.imageTransformer = imageTransformer
    }
    
    func didStartLoadingImageData(for model: FeedImage) {
        loadingView.display(FeedImageLoadingViewModel(isLoading: true))
        view.display(FeedImageViewModel<Image>(
            description: model.description,
            location: model.location,
            image: nil,
            shouldRetry: false))
    }
    
    func didFinishLoadingImageData(with data: Data, for model: FeedImage) {
        let image = imageTransformer(data)
        view.display(FeedImageViewModel<Image>(
            description: model.description,
            location: model.location,
            image: image,
            shouldRetry: image == nil))
        loadingView.display(FeedImageLoadingViewModel(isLoading: false))
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
    
    func test_didFinishLoadingImageData_displaysRetryOnFailedImageTransformationAndStopLoading() {
        let (sut, view) = makeSUT(imageTransformer: fail)
        let image = uniqueFeedImage()
        let data = Data()
        
        sut.didFinishLoadingImageData(with: data, for: image)
        
        XCTAssertFalse(view.isLoading)
        XCTAssertEqual(view.messages.count, 1)
        let message = view.messages.first
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertNil(message?.image)
        XCTAssertEqual(message?.shouldRetry, true)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(imageTransformer: @escaping (Data) -> Any? = { _ in nil },
                         file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: FeedImagePresenter<ViewSpy, Any>, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter(view: view, loadingView: view, imageTransformer: imageTransformer)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }
    
    private var fail: (Data) -> Any? {
        return { _ in nil }
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
