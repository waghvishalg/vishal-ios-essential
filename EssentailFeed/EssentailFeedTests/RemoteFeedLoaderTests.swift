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
        sut.load{ _ in }

        XCTAssertEqual(client.requestURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-url.com")!
        let (sut,client) = makeSut(url: url)
        sut.load{ _ in }
        sut.load{ _ in }

        XCTAssertEqual(client.requestURLs, [url,url])
    }
    
    func test_load_deliversErrorOnClientError(){
        let (sut, client) = makeSut()
        
        var capturedErrors = [RemoteFeedLoader.Error]()
        sut.load { capturedErrors.append($0) }
        
        let clientError = NSError(domain: "Test", code: 0)
        client.complete(with: clientError)
        
        XCTAssertEqual(capturedErrors, [.conectivity])
    }
    
    func test_load_deliversErrorOnNon200HttpResponse(){
        let (sut, client) = makeSut()
        
        let sample = [199, 201, 300, 400, 500]
        
        sample.enumerated().forEach { index, code in
            
            var capturedErrors = [RemoteFeedLoader.Error]()
            sut.load { capturedErrors.append($0) }
            
            client.complete(withStatusCode: code, at: index)
            
            XCTAssertEqual(capturedErrors, [.invalidData])
        }
    }
    
    // MARK: - Helpers
    
    private func makeSut(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader,client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        
        var requestURLs : [URL] {
            return messages.map { $0.url }
        }

        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url,completion))
        }
        
        func complete(with error: Error, at index: Int = 0){
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, at index: Int = 0){
            let response = HTTPURLResponse(
                url: requestURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!
            
            messages[index].completion(.success(response))
        }
    }

}
