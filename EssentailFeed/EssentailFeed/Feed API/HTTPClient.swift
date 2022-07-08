//
//  HTTPClient.swift
//  EssentailFeed
//
//  Created by Wagh, Vishal on 19/04/22.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    /// The completion hanlder can be invoked in any thread
    /// Clients are responsible to dispatch to approriates threads, if needed.
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
