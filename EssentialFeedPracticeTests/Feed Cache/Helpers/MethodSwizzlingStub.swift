//
//  MethodSwizzlingStub.swift
//  EssentialFeedPracticeTests
//
//  Created by Tsz-Lung on 15/09/2023.
//

import Foundation

class MethodSwizzlingStub<T: AnyObject>: NSObject {
    private let source: Selector
    private let destination: Selector

    init(source: Selector, destination: Selector) {
        self.source = source
        self.destination = destination
    }

    func startIntercepting() {
        method_exchangeImplementations(
            class_getInstanceMethod(T.self, source)!,
            class_getInstanceMethod(Self.self, destination)!
        )
    }

    deinit {
        method_exchangeImplementations(
            class_getInstanceMethod(Self.self, destination)!,
            class_getInstanceMethod(T.self, source)!
        )
    }
}
