//
//  CoreDataFeedStoreTests.swift
//  EssentailFeedTests
//
//  Created by Vishal Wagh on 05/07/22.
//

import XCTest
import EssentailFeed

class CoreDataFeedStoreTests: XCTestCase, FeedStoreSpecs {
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
    }
    
    func test_retrieve_hasNoSideEffectOnEmptyCache() {
        let sut = makeSUT()
        assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
    }
    
    func test_retrieve_deliversFoundValueOnNonEmptyCache() {
        
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        
    }
    
    func test_retrieve_deliversFailureOnRetirevalError() {
        
    }
    
    func test_retrieve_hasNoSideEffectsOnFailure() {
        
    }
    
    func test_insert_deliversNoErrorOnEmptyCache() {
        
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() {
        
    }
    
    func test_insert_overridesPreviouslyInsertedCacheValues() {
        
    }
    
    func test_insert_deliversErrorOnInsertionError() {
        
    }
    
    func test_insert_hasNoSideEffectsOnInsertonError() {
        
    }
    
    func test_delete_deliversNoErrorOnEmptyCache() {
        
    }
    
    func test_delete_hasNoSideEffectOnEmptyCache(){
        
    }
    
    func test_delete_deliversNoErrorOnNonEmptyCache(){
        
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        
    }
    
    func test_delete_deliversErrorOnDeletionError() {
        
    }
    
    func test_delete_hasNoSideEffectOnDeletionError() {
        
    }
    
    func test_storeSideEffects_runSerially(){
        
    }
    
    // - MARK: Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> FeedStore {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = URL(fileURLWithPath: "dev/null")
        let sut = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
        trackMemoryLeaks(sut, file: file, line: line)
        return sut
    }
}
