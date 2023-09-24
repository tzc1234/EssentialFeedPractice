//
//  MethodSwizzlingStub.swift
//  EssentialFeedPracticeTests
//
//  Created by Tsz-Lung on 15/09/2023.
//

import Foundation

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
