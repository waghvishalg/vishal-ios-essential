//
//  FeedViewControllerTest.swift
//  EssentailFeediOSTests
//
//  Created by Vishal Wagh on 03/01/23.
//

import XCTest

final class FeedViewController {
    convenience init(loader: FeedViewControllerTest.LoaderSpy) {
        self.init()
    }
}

final class FeedViewControllerTest: XCTestCase {
    
    func test_init_doesNotLoadFeed() {
        let loader = LoaderSpy()
        _ = FeedViewController(loader: loader)
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    // MARK: - Helpers
    
    class LoaderSpy {
        private(set) var loadCallCount: Int = 0
        
    }
    
}
