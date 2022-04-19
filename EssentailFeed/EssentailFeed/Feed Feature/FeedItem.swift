//
//  FeedItem.swift
//  EssentailFeed
//
//  Created by Wagh, Vishal on 13/04/22.
//

import Foundation

public struct FeedItem: Equatable{
    let id: UUID
    let descriptiom: String?
    let location: String?
    let imageURL: URL
}

