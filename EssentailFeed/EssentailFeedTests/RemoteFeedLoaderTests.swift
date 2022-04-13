//
//  RemoteFeedLoaderTests.swift
//  EssentailFeedTests
//
//  Created by Wagh, Vishal on 14/04/22.
//

import XCTest

class RemoteFeedLoader {
    
    let client: HTTPClient
    let url: URL
    
    init(url:URL, client: HTTPClient){
        self.url = url
        self.client = client
    }
    
    func load() {
        client.get(from: url)
    }
}

protocol HTTPClient {
    func get(from url: URL)
}

class HTTPClientSpy: HTTPClient {
    func get(from url: URL) {
        requestURL = url
    }
    
    var requestURL: URL?
}

class RemoteFeedLoaderTests: XCTestCase {
    
   
    func test_init_doesNotRequestDataFromURL(){
        let url = URL(string: "https://a-url.com")!
        let client = HTTPClientSpy()
        _ = RemoteFeedLoader(url: url, client: client)
        
        XCTAssertNil(client.requestURL)
    }
    
    func test_load_requestDataFromURL() {
        
        let url = URL(string: "https://a-given-url.com")!
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url,client: client)
        
        sut.load()
        
        XCTAssertEqual(client.requestURL, url)
    }
}
