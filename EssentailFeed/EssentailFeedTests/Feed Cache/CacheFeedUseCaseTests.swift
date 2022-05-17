//
//  CacheFeedUseCaseTests.swift
//  EssentailFeedTests
//
//  Created by Vishal Wagh on 16/05/22.
//

import XCTest
import EssentailFeed

class LocalFeedLoader {
    
    private let store: FeedStore
    private let currentDate: () -> Date
    init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(_ items: [FeedItem], completion: @escaping (Error?) -> Void){
        store.deletionCacheFeed { [unowned self]error in
            completion(error)
            if error == nil {
                self.store.insert(items, timestamp: self.currentDate())
            }
        }
    }
    
}

class FeedStore {
    
    typealias DeletionCompletion = (Error?) -> Void
    
    enum ReceivedMessage : Equatable {
        case deletCachedFeed
        case insert([FeedItem], Date)
    }
    private(set) var receivedMessage  = [ReceivedMessage]()
    
    private var delectCompletions = [DeletionCompletion]()
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
    
    func insert(_ items: [FeedItem],timestamp: Date) {
        receivedMessage.append(.insert(items, timestamp))
    }
    
}

class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessagStoreUponCreation(){
        let (_, store) = makeSUT()
        XCTAssertEqual(store.receivedMessage, [])
    }
    
    func test_save_requestCacheDeletion(){
        let (sut, store) = makeSUT()
        let items = [uniqueItem(),uniqueItem()]
        sut.save(items){ _ in }
        
        XCTAssertEqual(store.receivedMessage, [.deletCachedFeed])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(),uniqueItem()]
        let deletionError = anyNSError()
        
        sut.save(items){ _ in }
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.receivedMessage, [.deletCachedFeed])
    }
    
    func test_save_requestNewCacheInsetionWithTimestampOnSuccessfulDeletion(){
        let timestamp = Date()
        let items = [uniqueItem(),uniqueItem()]

        let (sut, store) = makeSUT(currentDate: { timestamp })
        
        sut.save(items){ _ in }
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.receivedMessage, [.deletCachedFeed, .insert(items, timestamp)])
    }
    
    
    func test_save_failsOnDeletionError() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(),uniqueItem()]
        let deletionError = anyNSError()
        
        let exp = expectation(description: "wait for the save completion")
        var receivedError: Error?
        sut.save(items) { error in
            receivedError = error
            exp.fulfill()
        }
        store.completeDeletion(with: deletionError)
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError as NSError?, deletionError)
    }
    
    
    //MARK: - Helper
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line:UInt = #line) -> (sut: LocalFeedLoader,store: FeedStore){
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackMemoryLeaks(store, file: file, line: line)
        trackMemoryLeaks(store)
        return (sut, store)
    }
    private func uniqueItem() -> FeedItem {
        return FeedItem(id: UUID(), description: "any desc", location: "any loc", imageURL: anyURL())
    }
    
    private func anyURL() -> URL{
       return URL(string: "http://any-url.com")!
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any Error", code: 0)
    }
}
