//
//  HTTPClient.swift
//  EssentailFeed
//
//  Created by Wagh, Vishal on 19/04/22.
//

import Foundation


public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>

    /// The completion hanlder can be invoked in any thread
    /// Clients are responsible to dispatch to approriates threads, if needed.
    func get(from url: URL, completion: @escaping (Result) -> Void)
}
