//
//  FeedStoreSpy.swift
//  EssentailFeedTests
//
//  Created by Vishal Wagh on 03/06/22.
//

import Foundation
import EssentailFeed

class FeedStoreSpy: FeedStore {
    enum ReceivedMessage : Equatable {
        case deletCachedFeed
        case insert([LocalFeedImage], Date)
        case retrieval
    }
    private(set) var receivedMessage  = [ReceivedMessage]()
    
    private var delectCompletions = [DeletionCompletion]()
    private var insertionCompletions = [InsertionCompletion]()
    private var retrievalCompletions = [RetrievalCompletion]()
    
    func deletionCacheFeed(completion: @escaping DeletionCompletion){
        delectCompletions.append(completion)
        receivedMessage.append(.deletCachedFeed)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        delectCompletions[index](.failure(error))
    }
    
    func completeDeletionSuccessfully(at index: Int = 0){
        delectCompletions[index](.success(()))
    }
    
    func insert(_ feed: [LocalFeedImage],timestamp: Date, completion: @escaping InsertionCompletion) {
        insertionCompletions.append(completion)
        receivedMessage.append(.insert(feed, timestamp))
    }
    
    func completeInsetion(with error: Error, at index: Int = 0) {
        insertionCompletions[index](.failure(error))
    }
    
    func completeInsetionSuccessfully(at index: Int = 0){
        insertionCompletions[index](.success(()))
    }
    
    func retrieve(completion: @escaping RetrievalCompletion){
        retrievalCompletions.append(completion)
        receivedMessage.append(.retrieval)
    }
    
    func completeRetrieval(with error: Error, at index: Int = 0){
        retrievalCompletions[index](.failure(error))
    }
    
    func completeRetrievalWithEmptyCache(at index: Int = 0) {
        retrievalCompletions[index](.success(.none))
    }
    
    func completeRetrieval(with feed: [LocalFeedImage], timeStamp:Date, at index: Int = 0) {
        retrievalCompletions[index](.success(.some(CacheFeed(feed: feed, timestamp: timeStamp))))
    }
    
}
