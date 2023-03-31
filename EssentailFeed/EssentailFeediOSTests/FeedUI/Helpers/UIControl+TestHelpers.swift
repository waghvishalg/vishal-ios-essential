//
//  UIControl+TestHelpers.swift
//  EssentailFeediOSTests
//
//  Created by Vishal Wagh on 31/03/23.
//

import UIKit
extension UIControl {
    func simulate(event : UIControl.Event) {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach{
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
