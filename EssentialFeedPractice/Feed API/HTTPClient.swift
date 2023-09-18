//
//  HTTPClient.swift
//  EssentialFeedPractice
//
//  Created by Tsz-Lung on 18/09/2023.
//

import Foundation

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    
    func get(from url: URL, completion: @escaping (Result) -> Void)
}
