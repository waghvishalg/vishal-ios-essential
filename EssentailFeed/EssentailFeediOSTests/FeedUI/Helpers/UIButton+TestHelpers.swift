//
//  UIButton+TestHelpers.swift
//  EssentailFeediOSTests
//
//  Created by Vishal Wagh on 31/03/23.
//

import UIKit

extension UIButton {
    func simulateTap() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
