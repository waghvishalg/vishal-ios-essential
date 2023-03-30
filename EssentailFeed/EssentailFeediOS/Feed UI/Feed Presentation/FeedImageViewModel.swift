//
//  FeedImageViewModel.swift
//  EssentailFeediOS
//
//  Created by Vishal Wagh on 29/03/23.
//

struct FeedImageViewModel<Image> {
    let description: String?
    let location: String?
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool
    
    var hasLocation: Bool {
        return location != nil
    }
}
