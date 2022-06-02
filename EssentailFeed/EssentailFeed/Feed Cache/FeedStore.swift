//
//  FeedStore.swift
//  EssentailFeed
//
//  Created by Vishal Wagh on 01/06/22.
//

import Foundation

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void

    func deletionCacheFeed(completion: @escaping DeletionCompletion)
    func insert(_ items: [LocalFeedItem],timestamp: Date, completion: @escaping InsertionCompletion)
}
