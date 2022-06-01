//
//  CacheFeedUseCaseTests.swift
//  EssentailFeedTests
//
//  Created by Vishal Wagh on 16/05/22.
//

import XCTest
import EssentailFeed

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
        let deletionError = anyNSError()
        
        expect(sut, toCompleteWithError: deletionError, when: {
            store.completeDeletion(with: deletionError)
        })
    }
    
    func test_save_failsOnInsertionError() {
        let (sut, store) = makeSUT()
        let insetionError = anyNSError()
        
        expect(sut, toCompleteWithError: insetionError, when: {
            store.completeDeletionSuccessfully()
            store.completeInsetion(with: insetionError)
        })
    }
    
    func test_save_succeedsOnSuccessfulCacheInsertion() {
        let (sut, store) = makeSUT()
        expect(sut, toCompleteWithError: nil, when: {
            store.completeDeletionSuccessfully()
            store.completeInsetionSuccessfully()
        })
    }
    
    func test_save_doesNotDeliverDeletionErrorAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var receivedResult = [LocalFeedLoader.SaveResult]()
        sut?.save([uniqueItem()]) { receivedResult.append($0) }
        
        sut = nil
        store.completeDeletion(with: anyNSError())
        
        XCTAssertTrue(receivedResult.isEmpty)
    }
    
    func test_save_doesNotDeliverInsetionErrorAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var receivedResult = [LocalFeedLoader.SaveResult]()
        sut?.save([uniqueItem()]) { receivedResult.append($0) }
        
        store.completeDeletionSuccessfully()
        sut = nil
        store.completeInsetion(with: anyNSError())

        XCTAssertTrue(receivedResult.isEmpty)
    }
    
    
    //MARK: - Helper
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line:UInt = #line) -> (sut: LocalFeedLoader,store: FeedStoreSpy){
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackMemoryLeaks(store, file: file, line: line)
        trackMemoryLeaks(store)
        return (sut, store)
    }
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWithError expectedError: NSError?, when action: () -> Void, file: StaticString = #file, line:UInt = #line){
        
        let exp = expectation(description: "wait for the save completion")
        var receivedError: Error?
        sut.save([uniqueItem()]) { error in
            receivedError = error
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError as NSError?, expectedError, file: file, line: line)
    }
    
    private class FeedStoreSpy: FeedStore {

        typealias DeletionCompletion = (Error?) -> Void
        typealias InsertionCompletion = (Error?) -> Void

        enum ReceivedMessage : Equatable {
            case deletCachedFeed
            case insert([FeedItem], Date)
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
        
        func insert(_ items: [FeedItem],timestamp: Date, completion: @escaping InsertionCompletion) {
            insertionCompletions.append(completion)
            receivedMessage.append(.insert(items, timestamp))
        }
        
        func completeInsetion(with error: Error, at index: Int = 0) {
            insertionCompletions[index](error)
        }
        
        func completeInsetionSuccessfully(at index: Int = 0){
            insertionCompletions[index](nil)
        }
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
