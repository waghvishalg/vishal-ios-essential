//
//  CodableFeedStoreTests.swift
//  EssentailFeedTests
//
//  Created by Vishal Wagh on 07/06/22.
//

import XCTest
import EssentailFeed

class CodableFeedStore {
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion){
        completion(.empty)
    }
}

class CodableFeedStoreTests: XCTestCase {
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = CodableFeedStore()
        let exp = expectation(description: "wait for cache retrieval")
        
        sut.retrieve{ result in
            switch result {
            case .empty:
                break
                
            default :
                XCTFail("Expectd empty result, got \(result) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
}
