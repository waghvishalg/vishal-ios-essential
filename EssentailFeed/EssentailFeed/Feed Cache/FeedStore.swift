//
//  FeedStore.swift
//  EssentailFeed
//
//  Created by Vishal Wagh on 01/06/22.
//

import Foundation

public enum RetrieveCachedFeedResult {
    case empty
    case found(feed:[LocalFeedImage], timstamp: Date)
    case failure(Error)
}

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    typealias RetrievalCompletion = (RetrieveCachedFeedResult) -> Void
    
    func deletionCacheFeed(completion: @escaping DeletionCompletion)
    func insert(_ feed: [LocalFeedImage],timestamp: Date, completion: @escaping InsertionCompletion)
    func retrieve(completion: @escaping RetrievalCompletion)
}
