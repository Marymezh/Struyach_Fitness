//
//  RateTableViewCell.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 26/4/23.
//

import UIKit
import StoreKit

final class RateTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let reuseIdentifier = "RateCell"
    
    let containerView: UIView = {
        let containerView = UIView()
        containerView.toAutoLayout()
        containerView.backgroundColor = .customTabBar
        return containerView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.toAutoLayout()
        label.text = "Rate this app".localized()
        label.textColor = .white
        return label
    }()
    
    private let imgView: UIImageView = {
        let imageView = UIImageView()
        imageView.toAutoLayout()
        imageView.image = UIImage(systemName: "star")
        imageView.tintColor = .systemGreen
        return imageView
    }()
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        self.backgroundColor = .customDarkGray
        
        let disclosureIndicator = UIImageView(image: UIImage(systemName: "chevron.right"))
        disclosureIndicator.contentMode = .scaleAspectFit
        disclosureIndicator.tintColor = .white
        accessoryView = disclosureIndicator
        
        self.addSubviews(containerView)
        containerView.addSubviews(imgView,titleLabel)
        
        let constraints = [
            containerView.topAnchor.constraint(equalTo: self.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15),
            containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            imgView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            imgView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 11),
            
            titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 45)
        
        ]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    // MARK: - Helper Functions
    
    func openAppRatingPage() {
        if let url = URL(string: "itms-apps://itunes.apple.com/app/id389801252") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            print ("unable to open app raiting page")
        }
    }
    
}
