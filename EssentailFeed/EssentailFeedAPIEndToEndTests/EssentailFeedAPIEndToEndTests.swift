//
//  EssentailFeedAPIEndToEndTests.swift
//  EssentailFeedAPIEndToEndTests
//
//  Created by Wagh, Vishal on 24/04/22.
//

import XCTest
import EssentailFeed

class EssentailFeedAPIEndToEndTests: XCTestCase {
    
    func test_endToEndTestServerGETFeedResult_matchesFixedTestAccountData(){
        
        let testServerURL = URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/feed")!
        let client = URLSessionHTTPClient()
        let loader = RemoteFeedLoader(url: testServerURL, client: client)
        
        let exp = expectation(description: "wair for load completion")
        
        var receivedResult: LoadFeedResult?
        loader.load{ result in
            receivedResult = result
            exp.fulfill()
        }
        wait(for: [exp], timeout: 6.0)
        
        switch receivedResult {
        case let .success(items)?:
            XCTAssertEqual(items.count,8,"Expcted 8 items in the test account feed")
            
        case let .failure(error)?:
            XCTFail("Expected successful feed result, got \(error) insated")
        default:
            XCTFail("Expected successful feed result, got no result insated")
        }
    }
}
