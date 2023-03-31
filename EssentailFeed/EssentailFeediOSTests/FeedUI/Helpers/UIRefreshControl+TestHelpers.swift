//
//  UIRefreshControl+TestHelpers.swift
//  EssentailFeediOSTests
//
//  Created by Vishal Wagh on 31/03/23.
//

import UIKit


extension UIRefreshControl {
    func simulatePullToRefresh() {
        simulate(event: .valueChanged)
    }
}
