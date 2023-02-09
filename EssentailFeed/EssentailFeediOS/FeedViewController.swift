//
//  FeedViewController.swift
//  EssentailFeediOS
//
//  Created by Vishal Wagh on 10/01/23.
//

import Foundation
import UIKit
import EssentailFeed

final public class FeedViewController: UITableViewController {
    public var loader: FeedLoader?
    
    public convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl =  UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        load()
    }
    
    @objc private func load() {
        refreshControl?.beginRefreshing()
        loader?.load { [weak self] _ in
            self?.refreshControl?.endRefreshing()
        }
    }
    
}
