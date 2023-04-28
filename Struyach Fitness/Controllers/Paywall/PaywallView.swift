//
//  PaywallView.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 25/4/23.
//

import UIKit

final class PaywallView: UIView {
    
    //MARK: - Properties
    
    private var smallInset: CGFloat { return 16 }
    private var bigInset: CGFloat { return 32 }
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.systemGreen
        label.font = UIFont.boldSystemFont(ofSize: 28)
        label.textAlignment = .center
        label.text = "Upgrade to Premium plan"
        label.adjustsFontSizeToFitWidth = true
        label.toAutoLayout()
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .justified
        label.numberOfLines = 0
        label.toAutoLayout()
        return label
    }()
    
    let payButton: UIButton = {
        let button = UIButton(type: .system)
        button.toAutoLayout()
        button.backgroundColor = UIColor.systemGreen
        button.layer.cornerRadius = 8
        button.setTitle("Upgrade for $9.99/month", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        return button
    }()
    
    let otherOptionsButton: UIButton = {
        let button = UIButton(type: .system)
        button.toAutoLayout()
        button.setTitle("Show other subscription options", for: .normal)
        button.setTitleColor(UIColor.systemGreen, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        let image = UIImage(systemName: "chevron.down")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = UIColor.systemGreen
        button.contentHorizontalAlignment = .center
        
        // set title and image insets
        let spacing: CGFloat = 6
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: -image!.size.width, bottom: -(image!.size.height + spacing), right: 0)
            button.imageEdgeInsets = UIEdgeInsets(top: -(button.titleLabel!.intrinsicContentSize.height + spacing), left: 0, bottom: 0, right: -button.titleLabel!.intrinsicContentSize.width)
        
        return button
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.spacing = 32
        stackView.toAutoLayout()
        return stackView
    }()
    
    //MARK: - Lifecycle
    
    init() {
        super.init(frame: .zero)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: setup
    
    private func setupSubviews() {
        self.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.addSubview(stackView)
        self.stackView.addArrangedSubview(titleLabel)
        self.stackView.addArrangedSubview(descriptionLabel)
        self.stackView.addArrangedSubview(payButton)
        self.stackView.addArrangedSubview(otherOptionsButton)
        
        let constraints = [
            stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: bigInset),
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: smallInset),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -smallInset),
            
            payButton.heightAnchor.constraint(equalToConstant: 60),
            otherOptionsButton.heightAnchor.constraint(equalToConstant: 40)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
}
