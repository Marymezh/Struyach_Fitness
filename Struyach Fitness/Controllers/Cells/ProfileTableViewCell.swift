//
//  ProfileTableViewCell.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 8/2/23.
//

import UIKit

final class ProfileTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "ProfileTableViewCell"
    
    private var baseInset: CGFloat { return 10 }
    
    let containerView: UIView = {
        let containerView = UIView()
        containerView.toAutoLayout()
        containerView.backgroundColor = .customTabBar
        return containerView
    }()
    
    let movementLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.toAutoLayout()
        return label
    }()
    
    let weightLabel: UILabel = {
        let label = UILabel()
        label.toAutoLayout()
        label.textColor = .white
        label.textAlignment = .right
        return label
    }()
    
    let weightTextField: UITextField = {
        let textField = UITextField()
        textField.tintColor = .systemGray
        textField.backgroundColor = .systemGray6
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField .frame.height))
        textField.leftViewMode = .always
        textField.keyboardType = .decimalPad
        textField.layer.borderColor = UIColor.black.cgColor
        textField.layer.borderWidth = 0.5
        textField.layer.cornerRadius = 5
        return textField
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .equalSpacing
        stackView.axis = .horizontal
        stackView.alignment = .leading
        stackView.toAutoLayout()
        return stackView
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupSubviews()
    }
    
    private func setupSubviews() {
        self.selectionStyle = .none
        self.backgroundColor = .customDarkGray
        contentView.addSubviews(containerView, stackView)
        
        stackView.addArrangedSubview(movementLabel)
        stackView.addArrangedSubview(weightLabel)
        stackView.addArrangedSubview(weightTextField)
        
        let constraints = [
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: baseInset),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -baseInset),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            movementLabel.widthAnchor.constraint(equalToConstant: 150),
            weightLabel.widthAnchor.constraint(equalToConstant: 70),
            weightTextField.widthAnchor.constraint(equalTo: weightLabel.widthAnchor),

            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: baseInset),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 25),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -25),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -baseInset)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
}
