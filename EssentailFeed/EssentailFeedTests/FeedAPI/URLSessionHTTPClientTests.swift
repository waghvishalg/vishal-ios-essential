//
//  URLSessionHTTPClientTests.swift
//  EssentailFeedTests
//
//  Created by Wagh, Vishal on 21/04/22.
//

import XCTest
import EssentailFeed

class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    
    init(session: URLSession = .shared){
        self.session = session
    }
    
    
    struct UnexpectedValuesRepresention: Error {}
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
            }else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success(data, response))
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
        let receivedError = resultErrorFor(data: nil, response: nil, error: anyNSError())
        // XCTAssertEqual(receivedError.code, requestError.code) Check this
        XCTAssertNotNil(receivedError)
    }
    
    func test_getFromURL_failsOnAllReprsentionCases(){
        
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPResponse(), error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyHTTPResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPResponse(), error: nil))

    }
    
    func test_getFromURL_successOnHTTPURLResponseData(){
        let data = anyData()
        let response = anyHTTPResponse()
        URLProtocolStub.stub(data: data, response: response, error: nil)
        
        let exp = expectation(description: "wait for request")
        makeSUT().get(from: anyURL()) { result in
            switch result {
            case let .success(receivedData, receivedResponse):
                XCTAssertEqual(receivedData, data)
                XCTAssertEqual(receivedResponse.url, response.url)
                XCTAssertEqual(receivedResponse.statusCode, response.statusCode)
            default:
                XCTFail("Expected success, got \(result) insted")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)

    }
    
    func test_getFromURL_successWithEmptyDataonHTTPResponseWithNilData(){
        
        let response = anyHTTPResponse()
        let receivedValue = resultValueFor(data: nil, response: response, error: nil)
                
        let emptyData = Data()
        XCTAssertEqual(receivedValue?.data, emptyData)
        XCTAssertEqual(receivedValue?.response.url, response.url)
        XCTAssertEqual(receivedValue?.response.statusCode, response.statusCode)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
        let sut = URLSessionHTTPClient()
        TrackMemoryLeaks(sut,file: file, line: line)
        return sut
    }
    
    private func resultErrorFor(data: Data?, response: URLResponse?, error: Error?,file: StaticString = #filePath, line: UInt = #line) -> Error? {
        
        let result = resultFor(data: data, response: response, error: error)
       
        switch result {
        case let .failure(error):
            return error
        default :
            XCTFail("Expected failure, got \(result) instead",file: file, line: line)
            return nil
        }
    }
    
    
    private func resultValueFor(data: Data?, response: URLResponse?, error: Error?,file: StaticString = #filePath, line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
        
        let result = resultFor(data: data, response: response, error: error)
        switch result {
        case let .success(data, response):
            return (data,response)
        default :
            XCTFail("Expected failure, got \(result) instead",file: file, line: line)
            return nil
        }
    }
    
    private func resultFor(data: Data?, response: URLResponse?, error: Error?,file: StaticString = #filePath, line: UInt = #line) -> HTTPClientResult {
        
        URLProtocolStub.stub(data: data, response: response, error: error)
        let sut = makeSUT(file: file, line: line)
        let exp = expectation(description: "Wait for completion")
        
        var receivedResult: HTTPClientResult!
        sut.get(from: anyURL()) { result in
            receivedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return receivedResult
    }
    
    private func anyURL() -> URL{
       return URL(string: "http://any-url.com")!
    }
    
    private func anyData() -> Data {
        return Data("anyData".utf8)
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any Error", code: 0)
    }
    
    private func anyHTTPResponse() -> HTTPURLResponse {
        return HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    
    private func nonHTTPResponse() -> URLResponse {
        return URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
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
