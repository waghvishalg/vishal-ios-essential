//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssentailFeedTests
//
//  Created by Vishal Wagh on 03/06/22.
//

import XCTest
import EssentailFeed

class LoadFeedFromCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessagStoreUponCreation(){
        let (_, store) = makeSUT()
        XCTAssertEqual(store.receivedMessage, [])
    }
    
    func test_load_requestCacheRetrieval(){
        let (sut, store) = makeSUT()
        
        sut.load{ _ in }
        XCTAssertEqual(store.receivedMessage, [.retrieval])
    }
    
    func test_load_fails_failsOnRtrieval(){
        let (sut, store) = makeSUT()
        let retrievalError = anyNSError()
        
        expect(sut, toCompleteWith: .failure(retrievalError)) {
            store.completeRetrieval(with: retrievalError)
        }
    }
    
    func test_load_deliversNoImagesOnEmptyCache(){
        let (sut, store) = makeSUT()
        expect(sut, toCompleteWith: .success([])) {
            store.completeRetrievalWithEmptyCache()
        }
    }
    
    func test_load_deliverCacheImageOnNonExpiredCache(){
        // deliver cache image on less than seven days old cache
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let nonExpiredTimeStamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        expect(sut, toCompleteWith: .success(feed.modules)) {
            store.completeRetrieval(with: feed.local, timeStamp: nonExpiredTimeStamp)
        }
    }
    
    func test_load_deliverNoImageOnCacheExpiration(){
        // deliver seven days old cache
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expirationTimeStamp = fixedCurrentDate.minusFeedCacheMaxAge()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        expect(sut, toCompleteWith: .success([])) {
            store.completeRetrieval(with: feed.local, timeStamp: expirationTimeStamp)
        }
    }
    
    func test_load_deliverNoImageOnExpiredCache(){
        // deliver cache more than seven days old cache
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let onExpiredTimeStamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        expect(sut, toCompleteWith: .success([])) {
            store.completeRetrieval(with: feed.local, timeStamp: onExpiredTimeStamp)
        }
    }
    
    func test_load_noSideEffectOnRetrievalError(){
        let (sut, store) = makeSUT()
        
        sut.load{ _ in }
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.receivedMessage, [.retrieval])
    }
    
    func test_load_noSideEffectOnEmptyCache(){
        let (sut, store) = makeSUT()
        
        sut.load{ _ in }
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertEqual(store.receivedMessage, [.retrieval])
    }
    
    func test_load_noSideEffectCacheOnNonExpiredCache(){
        // retrieval cache image  on less than seven days old cache
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let nonExpiredTimeStamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        sut.load{ _ in }
        store.completeRetrieval(with: feed.local, timeStamp: nonExpiredTimeStamp)
        
        XCTAssertEqual(store.receivedMessage, [.retrieval])
    }
    
    func test_load_noSideEffectOnCacheExpiration(){
        // retrieval seven days old cache
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expirationTimeStamp = fixedCurrentDate.minusFeedCacheMaxAge()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        sut.load{ _ in }
        store.completeRetrieval(with: feed.local, timeStamp: expirationTimeStamp)
        
        XCTAssertEqual(store.receivedMessage, [.retrieval])
    }
    
    func test_load_noSideEffectOnExpiredCache(){
        // retrieval cache more than seven days old cache
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expiredTimeStamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        sut.load{ _ in }
        store.completeRetrieval(with: feed.local, timeStamp: expiredTimeStamp)
        
        XCTAssertEqual(store.receivedMessage, [.retrieval])
    }
    
    func test_load_doesNotDeliversResultAfterSUTInstanceHasBeenDeallocated(){
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var receivedResults = [LocalFeedLoader.LoadResult]()
        sut?.load{ receivedResults.append($0) }
        
        sut = nil
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    //MARK: - Helper
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line:UInt = #line) -> (sut: LocalFeedLoader,store: FeedStoreSpy){
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackMemoryLeaks(store, file: file, line: line)
        trackMemoryLeaks(store)
        return (sut, store)
    }
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWith expectedResult: LocalFeedLoader.LoadResult, when action: () -> Void, file: StaticString = #file, line:UInt = #line){
        let exp = expectation(description: "Wait for laod completion")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedImages), .success(expectedImage)):
                XCTAssertEqual(receivedImages, expectedImage, file: file, line: line)
                
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead")
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
    }
}
