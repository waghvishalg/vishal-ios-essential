//
//  SharedTestHelper.swift
//  EssentailFeedTests
//
//  Created by Vishal Wagh on 05/06/22.
//

import Foundation

func anyNSError() -> NSError {
    return NSError(domain: "any Error", code: 0)
}

func anyURL() -> URL{
   return URL(string: "http://any-url.com")!
}
