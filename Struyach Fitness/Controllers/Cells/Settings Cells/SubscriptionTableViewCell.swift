//
//  SubscriptionTableViewCell.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 15/5/23.
//

import UIKit

class SubscriptionTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "SubscriptionsCell"
    
    let containerView: UIView = {
        let containerView = UIView()
        containerView.toAutoLayout()
        containerView.backgroundColor = .customTabBar
        return containerView
    }()
    
    let titleLabel: UILabel  = {
        let label = UILabel()
        label.toAutoLayout()
        label.textColor = .white
        return label
    }()
    
    let colorLabel: UILabel  = {
        let label = UILabel()
        label.toAutoLayout()
        label.layer.cornerRadius = 10
        label.layer.borderColor = UIColor.black.cgColor
        label.layer.borderWidth = 0.5
        label.clipsToBounds = true
        return label
    }()
    
    let termsLabel: UILabel = {
        let label = UILabel()
        label.toAutoLayout()
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .white
        return label
    }()

    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.toAutoLayout()
        return stackView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews() 
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        self.backgroundColor = .customDarkGray
        selectionStyle = .none
        contentView.addSubview(containerView)
        containerView.addSubview(stackView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(colorLabel)
        stackView.addArrangedSubview(termsLabel)
 
        let constraints = [
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            titleLabel.widthAnchor.constraint(equalToConstant: 160),
            termsLabel.widthAnchor.constraint(equalToConstant: 120),
            colorLabel.heightAnchor.constraint(equalToConstant: 20),
            colorLabel.widthAnchor.constraint(equalTo: colorLabel.heightAnchor),
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
    }

}
