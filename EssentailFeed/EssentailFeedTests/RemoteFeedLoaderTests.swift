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

class RemoteFeedLoaderTests: XCTestCase {
    
   
    func test_init_doesNotRequestDataFromURL(){
        let (_, client) = makeSut()
        
        XCTAssertNil(client.requestURL)
    }
    
    func test_load_requestDataFromURL() {
        let url = URL(string: "https://a-url.com")!
        let (sut,client) = makeSut(url: url)
        sut.load()

        XCTAssertEqual(client.requestURL, url)
    }
    
    // MARK: - Helpers
    
    private func makeSut(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader,client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
        
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestURL: URL?

        func get(from url: URL) {
            requestURL = url
        }
    }

}
