//
//  UIRefreshControl+Helpers.swift
//  EssentailFeediOS
//
//  Created by Vishal Wagh on 02/04/23.
//

import UIKit

extension UIRefreshControl {
    func update(isRefreshing: Bool) {
        isRefreshing ? beginRefreshing() : endRefreshing()
    }
}
