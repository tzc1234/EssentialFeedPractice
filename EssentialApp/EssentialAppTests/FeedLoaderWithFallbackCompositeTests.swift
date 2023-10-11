//
//  FeedLoaderWithFallbackCompositeTests.swift
//  EssentialAppTests
//
//  Created by Tsz-Lung on 10/10/2023.
//

import XCTest
import EssentialFeedPractice

final class FeedLoaderWithFallbackComposite: FeedLoader {
    private let remote: FeedLoader
    
    init(primary: FeedLoader, fallback: FeedLoader) {
        self.remote = primary
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        remote.load(completion: completion)
    }
}

final class FeedLoaderWithFallbackCompositeTests: XCTestCase {
    func test_load_deliversPrimaryFeedOnPrimaryLoaderSuccess() {
        let primaryFeed = uniqueFeed()
        let fallbackFeed = uniqueFeed()
        let sut = makeSUT(primaryResult: .success(primaryFeed), fallbackResult: .success(fallbackFeed))
        
        let exp = expectation(description: "Wait for load completion")
        sut.load { result in
            switch result {
            case let .success(receivedFeed):
                XCTAssertEqual(receivedFeed, primaryFeed)
            case .failure:
                XCTFail("Expect successful load feed result, got \(result) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(primaryResult: FeedLoader.Result, 
                         fallbackResult: FeedLoader.Result,
                         file: StaticString = #filePath,
                         line: UInt = #line) -> FeedLoader {
        let primaryLoader = LoaderStub(result: primaryResult)
        let fallbackLoader = LoaderStub(result: fallbackResult)
        let sut = FeedLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        trackForMemoryLeaks(primaryLoader, file: file, line: line)
        trackForMemoryLeaks(fallbackLoader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func uniqueFeed() -> [FeedImage] {
        [
            .init(id: UUID(),
                  description: "any description",
                  location: "any location",
                  url: URL(string: "https://any-url.com")!)
        ]
    }
    
    private func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(
                instance,
                "\(String(describing: instance.self)) should have deallocated. Potential memory leak.",
                file: file,
                line: line)
        }
    }
    
    private class LoaderStub: FeedLoader {
        private let result: FeedLoader.Result
        
        init(result: FeedLoader.Result) {
            self.result = result
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completion(result)
        }
    }
}
