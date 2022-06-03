//
//  FeedStoreSpy.swift
//  EssentailFeedTests
//
//  Created by Vishal Wagh on 03/06/22.
//

import Foundation
import EssentailFeed

class FeedStoreSpy: FeedStore {

    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void

    enum ReceivedMessage : Equatable {
        case deletCachedFeed
        case insert([LocalFeedImage], Date)
    }
    private(set) var receivedMessage  = [ReceivedMessage]()
    
    private var delectCompletions = [DeletionCompletion]()
    private var insertionCompletions = [InsertionCompletion]()

    func deletionCacheFeed(completion: @escaping DeletionCompletion){
        delectCompletions.append(completion)
        receivedMessage.append(.deletCachedFeed)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        delectCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0){
        delectCompletions[index](nil)
    }
    
    func insert(_ feed: [LocalFeedImage],timestamp: Date, completion: @escaping InsertionCompletion) {
        insertionCompletions.append(completion)
        receivedMessage.append(.insert(feed, timestamp))
    }
    
    func completeInsetion(with error: Error, at index: Int = 0) {
        insertionCompletions[index](error)
    }
    
    func completeInsetionSuccessfully(at index: Int = 0){
        insertionCompletions[index](nil)
    }
}
