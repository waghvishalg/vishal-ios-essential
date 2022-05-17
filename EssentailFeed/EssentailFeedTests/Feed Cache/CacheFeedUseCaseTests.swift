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
        store.deleteCacheFeedCount += 1
    }
}

class FeedStore {
    var deleteCacheFeedCount = 0
}

class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation(){
        let store = FeedStore()
        _ = LocalFeedLoader(store: store)
        
        XCTAssertEqual(store.deleteCacheFeedCount, 0)
    }
    
    func test_save_requestCacheDeletion(){
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        let items = [uniqueItem(),uniqueItem()]
        sut.save(items)
        
        XCTAssertEqual(store.deleteCacheFeedCount, 1)
    }
    
    //MARK: - Helper
    
    private func uniqueItem() -> FeedItem {
        return FeedItem(id: UUID(), description: "any desc", location: "any loc", imageURL: anyURL())
    }
    
    private func anyURL() -> URL{
       return URL(string: "http://any-url.com")!
    }
}
