//
//  FeedLoader.swift
//  EssentailFeed
//
//  Created by Wagh, Vishal on 13/04/22.
//

import Foundation

public protocol FeedLoader {
    typealias Result = Swift.Result<[FeedImage], Error>
    
    func load(completion: @escaping(Result) -> Void)
}
