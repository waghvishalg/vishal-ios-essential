//
//  FeedLoader.swift
//  EssentailFeed
//
//  Created by Wagh, Vishal on 13/04/22.
//

import Foundation

public enum LoadFeedResult{
    case success([FeedImage])
    case failure(Error)
}

public protocol FeedLoader {
    func load(completion: @escaping(LoadFeedResult) -> Void)
}
