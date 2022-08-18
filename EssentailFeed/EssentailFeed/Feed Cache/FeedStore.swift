//
//  FeedStore.swift
//  EssentailFeed
//
//  Created by Vishal Wagh on 01/06/22.
//

import Foundation


public typealias CacheFeed = (feed: [LocalFeedImage], timestamp: Date)

public protocol FeedStore {
    typealias DeletionResult = Error?
    typealias DeletionCompletion = (DeletionResult) -> Void
    
    typealias InsertionResult = Error?
    typealias InsertionCompletion = (InsertionResult) -> Void
    
    typealias RetrieveResult = Result<CacheFeed?, Error>
    typealias RetrievalCompletion = (RetrieveResult) -> Void
    
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
