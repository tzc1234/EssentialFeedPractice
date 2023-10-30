//
//  CommentsUIIntegrationTests.swift
//  EssentialAppTests
//
//  Created by Tsz-Lung on 30/10/2023.
//

import XCTest
import Combine
import UIKit
import EssentialFeedPractice
import EssentialFeedPracticeiOS
import EssentialApp

final class CommentsUIIntegrationTests: FeedUIIntegrationTests {
    func test_commentsView_hasTitle() {
        let (sut, _) = makeSUT()
        
        sut.simulateViewIsAppearing()
        
        XCTAssertEqual(sut.title, commentsTitle)
    }
    
    func test_loadCommentsActions_requestCommentsFromLoader() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadCommentsCallCount, 0, "Expect no loading requests before view is loaded")
        
        sut.simulateViewIsAppearing()
        XCTAssertEqual(loader.loadCommentsCallCount, 1, "Expect a loading request once view is loaded")
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCommentsCallCount, 2, "Expect another loading request once user initiates a load")
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCommentsCallCount, 3, "Expect a third loading request once user initiates another load")
    }
    
    func test_loadingCommentsIndicator_isVisibleWhileLoadingComments() {
        let (sut, loader) = makeSUT()
        let stub = UIRefreshControl.refreshingStub()
        stub.startIntercepting()
        
        sut.simulateViewIsAppearing()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expect loading indicator once view is loaded")
        
        loader.completeCommentsLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expect no loading indicator once loading completes successfully")
        
        sut.simulateUserInitiatedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expect loading indicator once user initiates a reload")
        
        loader.completeCommentsLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expect no loading indicator once user initiated loading completes with error")
    }
    
    func test_loadCommentsCompletion_rendersSuccessfullyLoadedComments() {
        let comment0 = makeComment(message: "a message", username: "a username")
        let comment1 = makeComment(message: "another message", username: "another username")
        let (sut, loader) = makeSUT()
        
        sut.simulateViewIsAppearing()
        assertThat(sut, isRendering: [])
        
        loader.completeCommentsLoading(with: [comment0], at: 0)
        assertThat(sut, isRendering: [comment0])
        
        sut.simulateUserInitiatedReload()
        loader.completeCommentsLoading(with: [comment0, comment1], at: 1)
        assertThat(sut, isRendering: [comment0, comment1])
    }
    
    func test_loadCommentsCompletion_doesNotAlterCurrentRenderedStateOnError() {
        let comment = makeComment()
        let (sut, loader) = makeSUT()
        
        sut.simulateViewIsAppearing()
        loader.completeCommentsLoading(with: [comment], at: 0)
        assertThat(sut, isRendering: [comment])
        
        sut.simulateUserInitiatedReload()
        loader.completeCommentsLoadingWithError(at: 1)
        assertThat(sut, isRendering: [comment])
    }
    
    func test_loadCommentsCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        sut.simulateViewIsAppearing()
        
        let exp = expectation(description: "Wait for background queue")
        DispatchQueue.global().async {
            loader.completeCommentsLoading(at: 0)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
    
    override func test_loadFeedErrorView_rendersErrorMessageOnErrorUntilNextReload() {
        let (sut, loader) = makeSUT()
        
        sut.simulateViewIsAppearing()
        XCTAssertNil(sut.errorMessage)
        
        loader.completeCommentsLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, loadError)
        
        sut.simulateUserInitiatedReload()
        XCTAssertNil(sut.errorMessage)
    }
    
    override func test_loadFeedErrorView_dismissesRenderErrorMessageAfterUserDismissedIt() {
        let (sut, loader) = makeSUT()
        
        sut.simulateViewIsAppearing()
        XCTAssertNil(sut.errorMessage)
        
        loader.completeCommentsLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, loadError)
        
        sut.simulateUserDismissedErrorView()
        XCTAssertNil(sut.errorMessage, "Expect no feed error message after user dismissed the feed error view")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: ListViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = CommentsUIComposer.commentsComposedWith(commentsLoader: loader.loadPublisher)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    private func assertThat(_ sut: ListViewController,
                            isRendering comments: [ImageComment],
                            file: StaticString = #filePath,
                            line: UInt = #line) {
        let renderedCommentCount = sut.numberOfRenderedCommentViews()
        guard renderedCommentCount == comments.count else {
            XCTFail(
                "Expect \(comments.count) comment views rendered, got \(renderedCommentCount) image views instead",
                file: file,
                line: line)
            return
        }
        
        let viewModel = ImageCommentsPresenter.map(comments)
        
        viewModel.comments.enumerated().forEach { index, comment in
            assertThat(sut, hasViewConfigureFor: comment, at: index, file: file, line: line)
        }
    }
    
    private func assertThat(_ sut: ListViewController,
                            hasViewConfigureFor comment: ImageCommentViewModel,
                            at index: Int,
                            file: StaticString = #filePath,
                            line: UInt = #line) {
        let view = sut.commentView(at: index)
        
        assertThat(view, hasViewConfigureFor: comment, at: index, file: file, line: line)
    }
    
    private func assertThat(_ view: ImageCommentCell?,
                            hasViewConfigureFor comment: ImageCommentViewModel,
                            at index: Int,
                            file: StaticString = #filePath,
                            line: UInt = #line) {
        XCTAssertEqual(
            view?.messageText,
            comment.message,
            "Expect message to be \(comment.message) for comment view at \(index)",
            file: file,
            line: line)
        
        XCTAssertEqual(
            view?.usernameText,
            comment.username,
            "Expect username to be \(comment.username) for comment view at \(index)",
            file: file,
            line: line)
        
        XCTAssertEqual(
            view?.dateText,
            comment.date,
            "Expect date to be \(comment.date) for comment view at \(index)",
            file: file,
            line: line)
    }
    
    private func makeComment(message: String = "any message",
                             username: String = "any username",
                             url: URL = anyURL()) -> ImageComment {
        ImageComment(id: UUID(), message: message, createdAt: .now, username: username)
    }
    
    private class LoaderSpy {
        private var requests = [PassthroughSubject<[ImageComment], Error>]()
        var loadCommentsCallCount: Int {
            requests.count
        }
        
        func loadPublisher() -> AnyPublisher<[ImageComment], Error> {
            let publisher = PassthroughSubject<[ImageComment], Error>()
            requests.append(publisher)
            return publisher.eraseToAnyPublisher()
        }
        
        func completeCommentsLoading(with comments: [ImageComment] = [], at index: Int = 0) {
            requests[index].send(comments)
            requests[index].send(completion: .finished)
        }
        
        func completeCommentsLoadingWithError(at index: Int = 0) {
            requests[index].send(completion: .failure(anyNSError()))
        }
    }
}

extension ImageCommentCell {
    var messageText: String? {
        messageLabel.text
    }
    
    var usernameText: String? {
        usernameLabel.text
    }
    
    var dateText: String? {
        dateLabel.text
    }
}
