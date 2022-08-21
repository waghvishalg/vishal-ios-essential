//
//  URLSessionHTTPClient.swift
//  EssentailFeed
//
//  Created by Wagh, Vishal on 23/04/22.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    
    public init(session: URLSession = .shared){
        self.session = session
    }
    
    
    private struct UnexpectedValuesRepresention: Error {}
    
    public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
        session.dataTask(with: url) { data, response, error in
            completion(Result {
                if let error = error {
                    throw error
                }else if let data = data, let response = response as? HTTPURLResponse {
                    return (data, response)
                }else {
                    throw UnexpectedValuesRepresention()
                }
            })
        }.resume()
    }
}
