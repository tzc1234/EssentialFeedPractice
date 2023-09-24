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
