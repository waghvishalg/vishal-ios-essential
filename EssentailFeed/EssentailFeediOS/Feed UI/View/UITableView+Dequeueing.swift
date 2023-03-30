//
//  UITableView+Dequeueing.swift
//  EssentailFeediOS
//
//  Created by Vishal Wagh on 30/03/23.
//

import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let identifier = String(describing: T.self)
        return dequeueReusableCell(withIdentifier: identifier) as! T
    }
}
