//
//  FeedImageCell.swift
//  EssentailFeediOS
//
//  Created by Vishal Wagh on 09/03/23.
//

import UIKit

public final class FeedImageCell: UITableViewCell {
    public let locationContainer = UIView()
    public let locationLable = UILabel()
    public let descriptionLable = UILabel()
    public let feedImageContainer = UIView()
    public let feedImageView = UIImageView()
    
    private(set) public lazy var feedImageRetryButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    var onRetry: (() ->  Void)?
    
    @objc private func retryButtonTapped() {
        onRetry?()
    }
}