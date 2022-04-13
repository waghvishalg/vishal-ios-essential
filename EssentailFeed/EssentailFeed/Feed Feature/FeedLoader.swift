//
//  FeedLoader.swift
//  EssentailFeed
//
//  Created by Wagh, Vishal on 13/04/22.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}

protocol FeedLoader {
    func load(completion: @escaping(LoadFeedResult) -> Void)
}
