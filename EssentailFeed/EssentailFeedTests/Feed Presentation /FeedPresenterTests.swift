//
//  FeedPresenterTest.swift
//  EssentailFeedTests
//
//  Created by Vishal Wagh on 01/04/23.
//

import XCTest

final class FeedPresenter {
    init(view: Any) {
        
    }
}


class FeedPresenterTests: XCTest {
    
    func test_init_doesNotSendMessagesToView() {
        let view = ViewSpy()
        
        _ = FeedPresenter(view: view)
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    
    // MARK: - Helpers
    
    private class ViewSpy {
        let messages = [Any]()
    }
}
