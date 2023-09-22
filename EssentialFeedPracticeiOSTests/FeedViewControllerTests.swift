//
//  FeedViewControllerTests.swift
//  EssentialFeedPracticeiOSTests
//
//  Created by Tsz-Lung on 21/09/2023.
//

import XCTest
import UIKit
import EssentialFeedPractice
import EssentialFeedPracticeiOS

final class FeedViewControllerTests: XCTestCase {
    func test_loadFeedActions_requestFeedFromLoader() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadCallCount, 0, "Expect no loading requests before view is loaded")
        
        sut.simulateViewIsAppearing()
        XCTAssertEqual(loader.loadCallCount, 1, "Expect a loading request once view is loaded")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 2, "Expect another loading request once user initiates a load")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 3, "Expect a third loading request once user initiates another load")
    }
    
    func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
        let (sut, loader) = makeSUT()
        let stub = UIRefreshControl.MethodSwizzlingStub()
        stub.startIntercepting()
        
        sut.simulateViewIsAppearing()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expect loading indicator once view is loaded")
        
        loader.completeFeedLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expect no loading indicator once loading is completed")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expect loading indicator once user initiates a reload")
        
        loader.completeFeedLoading(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expect no loading indicator once user initiated loading is completed")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    private class LoaderSpy: FeedLoader {
        private var completions = [(FeedLoader.Result) -> Void]()
        
        var loadCallCount: Int {
            completions.count
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completions.append(completion)
        }
        
        func completeFeedLoading(at index: Int = 0) {
            completions[index](.success([]))
        }
    }
}

extension FeedViewController {
    func simulateViewIsAppearing() {
        beginAppearanceTransition(true, animated: false)
        endAppearanceTransition()
    }
    
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    var isShowingLoadingIndicator: Bool {
        refreshControl?.isRefreshing == true
    }
}

private extension UIRefreshControl {
    class MethodSwizzlingStub: NSObject {
        struct MethodPair {
            let source: Selector
            let destination: Selector
        }
        
        @objc private(set) var isRefreshing = false
        
        private let destinationClass = UIRefreshControl.self
        private let methodPairs = [
            MethodPair(
                source: #selector(getter: isRefreshing),
                destination: #selector(getter: UIRefreshControl.isRefreshing)
            ),
            MethodPair(
                source: #selector(beginRefreshing),
                destination: #selector(UIRefreshControl.beginRefreshing)
            ),
            MethodPair(
                source: #selector(endRefreshing),
                destination: #selector(UIRefreshControl.endRefreshing)
            )
        ]
        
        override init() {}

        @objc func beginRefreshing() {
            isRefreshing = true
        }
        
        @objc func endRefreshing() {
            isRefreshing = false
        }
        
        func startIntercepting() {
            methodPairs.forEach { pair in
                method_exchangeImplementations(
                    class_getInstanceMethod(Self.self, pair.source)!,
                    class_getInstanceMethod(destinationClass, pair.destination)!
                )
            }
        }

        deinit {
            methodPairs.forEach { pair in
                method_exchangeImplementations(
                    class_getInstanceMethod(destinationClass, pair.destination)!,
                    class_getInstanceMethod(Self.self, pair.source)!
                )
            }
        }
    }
    
    func simulatePullToRefresh() {
        allTargets.forEach{ target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach { action in
                (target as NSObject).perform(Selector(action))
            }
        }
    }
}
