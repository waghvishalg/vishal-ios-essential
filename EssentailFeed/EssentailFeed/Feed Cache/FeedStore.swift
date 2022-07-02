//
//  FeedStore.swift
//  EssentailFeed
//
//  Created by Vishal Wagh on 01/06/22.
//

import Foundation

public enum RetrieveCachedFeedResult {
    case empty
    case found(feed:[LocalFeedImage], timestamp: Date)
    case failure(Error)
}

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    typealias RetrievalCompletion = (RetrieveCachedFeedResult) -> Void
    
    /// The completion hanlder can be invoked in any thread
    /// Clients are responsible to dispatch to approriates threads, if needed.
    func deletionCacheFeed(completion: @escaping DeletionCompletion)
    
    /// The completion hanlder can be invoked in any thread
    /// Clients are responsible to dispatch to approriates threads, if needed.
    func insert(_ feed: [LocalFeedImage],timestamp: Date, completion: @escaping InsertionCompletion)
    
    /// The completion hanlder can be invoked in any thread
    /// Clients are responsible to dispatch to approriates threads, if needed.
    func retrieve(completion: @escaping RetrievalCompletion)
}
