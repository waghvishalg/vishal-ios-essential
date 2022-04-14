//
//  RemoteFeedLoaderTests.swift
//  EssentailFeedTests
//
//  Created by Wagh, Vishal on 14/04/22.
//

import XCTest
import EssentailFeed

class RemoteFeedLoaderTests: XCTestCase {
    
   
    func test_init_doesNotRequestDataFromURL(){
        let (_, client) = makeSut()
        
        XCTAssertTrue(client.requestURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://a-url.com")!
        let (sut,client) = makeSut(url: url)
        sut.load()
        sut.load()

        XCTAssertEqual(client.requestURLs, [url, url])
    }
    
    // MARK: - Helpers
    
    private func makeSut(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader,client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestURLs =  [URL]()
        
        func get(from url: URL) {
            requestURLs.append(url)
        }
    }

}
