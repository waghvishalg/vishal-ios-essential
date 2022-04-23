//
//  URLSessionHTTPClientTests.swift
//  EssentailFeedTests
//
//  Created by Wagh, Vishal on 21/04/22.
//

import XCTest
import EssentailFeed

class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession = .shared){
        self.session = session
    }
    
    
    struct UnexpectedValuesRepresention: Error {}
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error = error {
                completion(.failure(error))
            }else {
                completion(.failure(UnexpectedValuesRepresention()))
            }
        }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    
    
    override func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequest()
    }
    
    override func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptingRequest()
    }
    
    func test_getFromURL_peformsGETRequestWithURL(){
        let url = anyURL()
        let exp = expectation(description: "wait for request")
        URLProtocolStub.obserbveRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        makeSUT().get(from: url) { _ in }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_getFromURL_failsOnRequestError(){
        let requestError = NSError(domain: "any Error", code: 0)
        let receivedError = resultErrorFor(data: nil, response: nil, error: requestError)
        // XCTAssertEqual(receivedError.code, requestError.code) Check this
        XCTAssertNotNil(receivedError)
    }
    
    func test_getFromURL_failsOnAllReprsentionCases(){
        let anyData = Data("anyData".utf8)
        let anyError = NSError(domain: "any Error", code: 0)
        let nonHTTPResponse = URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
        let anyHTTPResponse = HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)
        
        
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPResponse, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPResponse, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData, response: nil, error: anyError))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPResponse, error: anyError))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPResponse, error: anyError))
        XCTAssertNotNil(resultErrorFor(data: anyData, response: nonHTTPResponse, error: anyError))
        XCTAssertNotNil(resultErrorFor(data: anyData, response: anyHTTPResponse, error: anyError))
        XCTAssertNotNil(resultErrorFor(data: anyData, response: nonHTTPResponse, error: nil))


    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> URLSessionHTTPClient {
        let sut = URLSessionHTTPClient()
        TrackMemoryLeaks(sut,file: file, line: line)
        return sut
    }
    
    private func resultErrorFor(data: Data?, response: URLResponse?, error: Error?,file: StaticString = #filePath, line: UInt = #line) -> Error? {
        
        URLProtocolStub.stub(data: data, response: response, error: error)
        
        let exp = expectation(description: "Wait for completion")
        
        var receivedError: Error?
        makeSUT(file: file, line: line).get(from: anyURL()) { result in
            switch result {
            case let .failure(error):
                receivedError = error
            default :
                XCTFail("Expected failure, got \(result) instead",file: file, line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return receivedError
    }
    
    private func anyURL() -> URL{
       return URL(string: "http://any-url.com")!
    }
    
    private class URLProtocolStub: URLProtocol {
        private static var stub: Stub?
        private static var requestObserver: ((URLRequest) ->Void)?
        
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func stub(data: Data?, response: URLResponse? ,error: Error?){
            stub = Stub(data: data, response: response, error: error)
        }
            
        static func startInterceptingRequest(){
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        static func stopInterceptingRequest(){
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
        }
        
        static func obserbveRequests(observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }
        override class func canInit(with request: URLRequest) -> Bool {
            requestObserver?(request)
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            
            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }
    
}
