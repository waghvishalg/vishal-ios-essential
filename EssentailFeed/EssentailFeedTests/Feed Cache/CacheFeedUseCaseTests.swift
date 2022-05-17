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
    init(store: FeedStore) {
        self.store = store
    }
    
    func save(_ items: [FeedItem]){
        store.deletionCacheFeed { [unowned self]error in
            if error == nil {
                self.store.insert(items)
            }
        }
    }
    
}

class FeedStore {
    
    typealias DeletionCompletion = (Error?) -> Void
    var deleteCacheFeedCount = 0
    var inserionCallCount = 0
    
    private var delectCompletions = [DeletionCompletion]()
    func deletionCacheFeed(completion: @escaping DeletionCompletion){
        deleteCacheFeedCount += 1
        delectCompletions.append(completion)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        delectCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0){
        delectCompletions[index](nil)
    }
    
    func insert(_ items: [FeedItem]) {
        inserionCallCount += 1
        
    }
    
}

class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation(){
        let (_, store) = makeSUT()
        XCTAssertEqual(store.deleteCacheFeedCount, 0)
    }
    
    func test_save_requestCacheDeletion(){
        let (sut, store) = makeSUT()
        let items = [uniqueItem(),uniqueItem()]
        sut.save(items)
        
        XCTAssertEqual(store.deleteCacheFeedCount, 1)
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(),uniqueItem()]
        let deletionError = anyNSError()
        
        sut.save(items)
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.inserionCallCount, 0)
    }
    
    func test_save_requestNewCacheInsetionOnSuccessfulDeletion(){
        let (sut, store) = makeSUT()
        let items = [uniqueItem(),uniqueItem()]
        
        sut.save(items)
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.inserionCallCount, 1)
    }
    
    //MARK: - Helper
    
    private func makeSUT(file: StaticString = #file, line:UInt = #line) -> (sut: LocalFeedLoader,store: FeedStore){
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
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
