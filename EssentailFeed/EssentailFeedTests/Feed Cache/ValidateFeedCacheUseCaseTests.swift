//
//  ValidateFeedCacheUseCaseTests.swift
//  EssentailFeedTests
//
//  Created by Vishal Wagh on 05/06/22.
//

import XCTest
import EssentailFeed

class ValidateFeedCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessagStoreUponCreation(){
        let (_, store) = makeSUT()
        XCTAssertEqual(store.receivedMessage, [])
    }
    
    func test_validateCache_deletesCacheOnRetrievalError(){
        let (sut, store) = makeSUT()
        
        sut.validateCache()
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.receivedMessage, [.retrieval, .deletCachedFeed])
    }
    
    func test_ValidateCache_doesNotDeletesCacheOnEmptyCache(){
        let (sut, store) = makeSUT()
        
        sut.validateCache()
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertEqual(store.receivedMessage, [.retrieval])
    }
    
    func test_load_doesNotDeletesCacheOnLessThanSevenDaysOldCache(){
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let lessThanSevenDaysOldTimeStamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        sut.load{ _ in }
        store.completeRetrieval(with: feed.local, timeStamp: lessThanSevenDaysOldTimeStamp)
        
        XCTAssertEqual(store.receivedMessage, [.retrieval])
    }
    
    //MARK: - Helper
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line:UInt = #line) -> (sut: LocalFeedLoader,store: FeedStoreSpy){
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackMemoryLeaks(store, file: file, line: line)
        trackMemoryLeaks(store)
        return (sut, store)
    }
    
}
