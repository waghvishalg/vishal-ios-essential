//
//  CoreDataFeedStore.swift
//  EssentailFeed
//
//  Created by Vishal Wagh on 05/07/22.
//

import Foundation

public final class CoreDataFeedStore: FeedStore {
    
    public init() {}

    public func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }

    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion){

    }

    public func deletionCacheFeed(completion: @escaping DeletionCompletion) {

    }
}
