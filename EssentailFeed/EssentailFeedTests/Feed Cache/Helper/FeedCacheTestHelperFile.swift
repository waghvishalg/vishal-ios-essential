//
//  FeedCacheTestHelperFile.swift
//  EssentailFeedTests
//
//  Created by Vishal Wagh on 05/06/22.
//

import Foundation
import EssentailFeed

func uniqueImage() -> FeedImage {
    return FeedImage(id: UUID(), description: "any desc", location: "any loc", url: anyURL())
}

func uniqueImageFeed() -> (modules: [FeedImage], local: [LocalFeedImage]) {
    let modules = [uniqueImage(),uniqueImage()]
    let local = modules.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    
    return (modules, local)
}

extension Date {
    
    func minusFeedCacheMaxAge() -> Date{
        return adding(days: -feedCacheMaxAgeDays)
    }
    
    private var feedCacheMaxAgeDays: Int{
        return 7
    }
    func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
