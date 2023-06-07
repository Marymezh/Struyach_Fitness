//
//  HideEmailTableViewCell.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 7/6/23.
//

import UIKit

final class HideEmailTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    static let reuseIdentifier = "HideEmailCell"
    
    var programName: String?
    
    let containerView: UIView = {
        let containerView = UIView()
        containerView.toAutoLayout()
        containerView.backgroundColor = .customTabBar
        return containerView
    }()
    
    private let imgView: UIImageView = {
        let imageView = UIImageView()
        imageView.toAutoLayout()
        imageView.image = UIImage(systemName: "envelope")
        imageView.tintColor = .systemGreen
        return imageView
    }()
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = .white
        label.text = "Profile email is hidden".localized()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var hideEmailSwitch: UISwitch = {
        let notificationSwitch = UISwitch()
        notificationSwitch.translatesAutoresizingMaskIntoConstraints = false
        return notificationSwitch
    }()
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Configuration
    
    private func configureUI() {
        selectionStyle = .none
        self.backgroundColor = .customDarkGray
        contentView.addSubview(containerView)
        containerView.addSubviews(imgView, titleLabel, hideEmailSwitch)
        
        let constraints = [
            containerView.topAnchor.constraint(equalTo: self.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15),
            containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            imgView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            imgView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            
            titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 45),
       
            hideEmailSwitch.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            hideEmailSwitch.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}
