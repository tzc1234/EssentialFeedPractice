//
//  CommonHelpers.swift
//  EssentialAppTests
//
//  Created by Tsz-Lung on 11/10/2023.
//

import Foundation

func anyNSError() -> NSError {
    NSError(domain: "any", code: 0)
}

func anyData() -> Data {
    Data("any data".utf8)
}

func anyURL() -> URL {
    URL(string: "https://any-url.com")!
}
