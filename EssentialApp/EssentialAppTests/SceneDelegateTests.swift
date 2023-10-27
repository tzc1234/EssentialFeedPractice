//
//  SceneDelegateTests.swift
//  EssentialAppTests
//
//  Created by Tsz-Lung on 16/10/2023.
//

import XCTest
import EssentialFeedPracticeiOS
@testable import EssentialApp

final class SceneDelegateTests: XCTestCase {
    func test_configureWindow_configuresRootViewController() {
        let sut = SceneDelegate()
        sut.window = UIWindow()
        
        sut.configureWindow()
        
        let root = sut.window?.rootViewController
        let rootNavigation = root as? UINavigationController
        let topController = rootNavigation?.topViewController
        XCTAssertNotNil(
            rootNavigation,
            "Expect a navigation controller as root, got \(String(describing: root)) instead")
        XCTAssertTrue(
            topController is ListViewController,
            "Expect a feed view controller as top view controller, got \(String(describing: topController)) instead")
    }
    
    func test_configureWindow_setsWindowAsKeyAndVisible() {
        let sut = SceneDelegate()
        let window = UIWindowSpy()
        sut.window = window
        
        sut.configureWindow()
        
        XCTAssertEqual(window.makeKeyAndVisibleCallCounts, 1)
    }
    
    private class UIWindowSpy: UIWindow {
        private(set) var makeKeyAndVisibleCallCounts = 0
        
        override func makeKeyAndVisible() {
            makeKeyAndVisibleCallCounts += 1
        }
    }
}
