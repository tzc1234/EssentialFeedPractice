//
//  UIRefreshControl+TestHelpers.swift
//  EssentialFeedPracticeiOSTests
//
//  Created by Tsz-Lung on 23/09/2023.
//

import UIKit

extension UIRefreshControl {
    static func refreshingStub() -> Stub {
        Stub(methodPairs: [
            .init(
                source: #selector(getter: Stub.isRefreshing),
                destination: #selector(getter: UIRefreshControl.isRefreshing)
            ),
            .init(
                source: #selector(Stub.beginRefreshing),
                destination: #selector(UIRefreshControl.beginRefreshing)
            ),
            .init(
                source: #selector(Stub.endRefreshing),
                destination: #selector(UIRefreshControl.endRefreshing)
            )
        ])
    }
    
    class Stub: MethodSwizzlingStub<UIRefreshControl> {
        @objc private(set) var isRefreshing = false
        
        @objc func beginRefreshing() {
            isRefreshing = true
        }
        
        @objc func endRefreshing() {
            isRefreshing = false
        }
    }
    
    func simulatePullToRefresh() {
        simulate(event: .valueChanged)
    }
}

class MethodSwizzlingStub<T: AnyObject>: NSObject {
    struct MethodPair {
        let source: Selector
        let destination: Selector
    }
    
    private let methodPairs: [MethodPair]
    
    init(methodPairs: [MethodPair]) {
        self.methodPairs = methodPairs
    }

    func startIntercepting() {
        methodPairs.forEach { pair in
            method_exchangeImplementations(
                class_getInstanceMethod(T.self, pair.source)!,
                class_getInstanceMethod(Self.self, pair.destination)!
            )
        }
    }

    deinit {
        methodPairs.forEach { pair in
            method_exchangeImplementations(
                class_getInstanceMethod(Self.self, pair.destination)!,
                class_getInstanceMethod(T.self, pair.source)!
            )
        }
    }
}
