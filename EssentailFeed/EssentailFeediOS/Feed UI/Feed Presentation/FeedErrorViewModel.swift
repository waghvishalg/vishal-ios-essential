//
//  FeedErrorViewModel.swift
//  EssentailFeediOS
//
//  Created by Vishal Wagh on 02/04/23.
//


struct FeedErrorViewModel {
    let message: String?

    static var noError: FeedErrorViewModel {
        return FeedErrorViewModel(message: nil)
    }

    static func error(message: String) -> FeedErrorViewModel {
        return FeedErrorViewModel(message: message)
    }
}
