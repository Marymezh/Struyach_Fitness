//
//  SubscriptionTableViewCell.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 15/5/23.
//

import UIKit

class SubscriptionTableViewCell: UITableViewCell {
    
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
        addSubview(stackView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(colorLabel)
        stackView.addArrangedSubview(termsLabel)
 
        let constraints = [
            titleLabel.widthAnchor.constraint(equalToConstant: 180),
            termsLabel.widthAnchor.constraint(equalToConstant: 120),
            colorLabel.heightAnchor.constraint(equalToConstant: 20),
            colorLabel.widthAnchor.constraint(equalTo: colorLabel.heightAnchor),
            stackView.topAnchor.constraint(equalTo: self.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
    }

}
