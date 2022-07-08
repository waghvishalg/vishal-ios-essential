//
//  XCTestCase+MemoryLeakTracking.swift
//  EssentailFeedTests
//
//  Created by Wagh, Vishal on 23/04/22.
//

import XCTest

extension XCTestCase {
    func trackMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated, Potential memory leek.", file: file, line: line)
        }
    }
    
}
