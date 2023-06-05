//
//  SignOutTableViewCell.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 1/5/23.
//

import UIKit

class ManagementTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let reuseIdentifier = "ManagementCell"
    
    let containerView: UIView = {
        let containerView = UIView()
        containerView.toAutoLayout()
        containerView.backgroundColor = .customTabBar
        return containerView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.toAutoLayout()
        label.textColor = .red
        return label
    }()
    
    let imgView: UIImageView = {
        let imageView = UIImageView()
        imageView.toAutoLayout()
        imageView.tintColor = .red
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
        selectionStyle = .none
        contentView.addSubview(containerView)
        containerView.addSubviews(imgView, titleLabel)
        
        let constraints = [
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            imgView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            imgView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 11),
            
            titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 45)
        
        ]
        
        NSLayoutConstraint.activate(constraints)
        
    }

  }
