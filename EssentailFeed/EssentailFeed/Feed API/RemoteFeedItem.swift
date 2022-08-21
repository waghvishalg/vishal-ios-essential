//
//  RemoteFeedItem.swift
//  EssentailFeed
//
//  Created by Vishal Wagh on 02/06/22.
//

import Foundation

struct RemoteFeedItem: Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
}
