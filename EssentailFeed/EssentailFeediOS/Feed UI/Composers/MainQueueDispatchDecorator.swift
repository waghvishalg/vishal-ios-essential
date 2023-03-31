//
//  MainQueueDispatchDecorator.swift
//  EssentailFeediOS
//
//  Created by Vishal Wagh on 31/03/23.
//

import Foundation
import EssentailFeed

final class MainQueueDispatchDecorator<T> {
    private let decorate: T
    
    init(decorate: T) {
        self.decorate = decorate
    }
    
    func dispatch(completion: @escaping () -> Void) {
        guard Thread.isMainThread else {
            return DispatchQueue.main.async(execute: completion)
        }
        completion()
    }
}

extension MainQueueDispatchDecorator: FeedLoader where T == FeedLoader {
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decorate.load { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: FeedImageDataLoader where T == FeedImageDataLoader {
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        return decorate.loadImageData(from: url) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}
