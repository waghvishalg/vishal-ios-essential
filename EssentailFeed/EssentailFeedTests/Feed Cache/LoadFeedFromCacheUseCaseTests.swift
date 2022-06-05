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
    
    func test_load_deliverCacheImageOnlessThanSevenDaysOldCache(){
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let lessThanSevenDaysOldTimeStamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        expect(sut, toCompleteWith: .success(feed.modules)) {
            store.completeRetrieval(with: feed.local, timeStamp: lessThanSevenDaysOldTimeStamp)
        }
    }
    
    func test_load_deliverNoImageOnSevenDaysOldCache(){
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let sevenDaysOldTimeStamp = fixedCurrentDate.adding(days: -7)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        expect(sut, toCompleteWith: .success([])) {
            store.completeRetrieval(with: feed.local, timeStamp: sevenDaysOldTimeStamp)
        }
    }
    
    func test_load_deliverNoImageOnMoreThanSevenDaysOldCache(){
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let moreThanSevenDaysOldTimeStamp = fixedCurrentDate.adding(days: -7).adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        expect(sut, toCompleteWith: .success([])) {
            store.completeRetrieval(with: feed.local, timeStamp: moreThanSevenDaysOldTimeStamp)
        }
    }
    
    func test_load_noSideEffectOnRetrievalError(){
        let (sut, store) = makeSUT()
        
        sut.load{ _ in }
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.receivedMessage, [.retrieval])
    }
    
    func test_load_doesNotDeletesCacheOnEmptyCache(){
        let (sut, store) = makeSUT()
        
        sut.load{ _ in }
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
    
    func test_load_deletesSevenDaysOldCache(){
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let sevenDaysOldTimeStamp = fixedCurrentDate.adding(days: -7)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        sut.load{ _ in }
        store.completeRetrieval(with: feed.local, timeStamp: sevenDaysOldTimeStamp)
        
        XCTAssertEqual(store.receivedMessage, [.retrieval, .deletCachedFeed])
    }
    
    func test_load_deletesCacheMoreThanSevenDaysOldCache(){
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let sevenDaysOldTimeStamp = fixedCurrentDate.adding(days: -7).adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        sut.load{ _ in }
        store.completeRetrieval(with: feed.local, timeStamp: sevenDaysOldTimeStamp)
        
        XCTAssertEqual(store.receivedMessage, [.retrieval, .deletCachedFeed])
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
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any Error", code: 0)
    }
    
    private func anyURL() -> URL{
       return URL(string: "http://any-url.com")!
    }
    
    private func uniqueImage() -> FeedImage {
        return FeedImage(id: UUID(), description: "any desc", location: "any loc", url: anyURL())
    }
    
    private func uniqueImageFeed() -> (modules: [FeedImage], local: [LocalFeedImage]) {
        let modules = [uniqueImage(),uniqueImage()]
        let local = modules.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
        
        return (modules, local)
    }
}

private extension Date {
    func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
