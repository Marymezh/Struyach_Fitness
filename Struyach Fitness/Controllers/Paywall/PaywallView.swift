//
//  PaywallView.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 25/4/23.
//

import UIKit

class PaywallView: UIView {
    
    private var smallInset: CGFloat { return 16 }
    private var bigInset: CGFloat { return 32 }
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.systemGreen
        label.font = UIFont.boldSystemFont(ofSize: 28)
        label.textAlignment = .center
        label.text = "Upgrade to Premium plan"
        label.toAutoLayout()
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "ECD training plan is the best choise, if you have an access to a gym or crossfit box. \n\nIt is a perfect plan to keep fit and improve your skills in all most common movements. The plan is updated each week day, you can comment your results and ask for support of the experienced coach at any time! \n\nAlso you can compare your results with ones from ECD club members posting their results every evening. \n\nSo don't hesitate and join now!!!"
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
    
    let backgroundView: UIView = {
        let view = UIView()
        view.toAutoLayout()
        view.backgroundColor = .black
        view.alpha = 0.5
        return view
    }()
    
    init() {
        super.init(frame: .zero)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.addSubviews(backgroundView, titleLabel, descriptionLabel, payButton, otherOptionsButton)
        
        let constraints = [
            backgroundView.topAnchor.constraint(equalTo: self.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: bigInset),
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: smallInset),
            titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -smallInset),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: smallInset),
            descriptionLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: smallInset),
            descriptionLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -smallInset),
            
            payButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: bigInset),
            payButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: bigInset),
            payButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -bigInset),
            payButton.heightAnchor.constraint(equalToConstant: 60),
            
            otherOptionsButton.topAnchor.constraint(equalTo: payButton.bottomAnchor, constant: 10),
            otherOptionsButton.trailingAnchor.constraint(equalTo: payButton.trailingAnchor),
            otherOptionsButton.leadingAnchor.constraint(equalTo: payButton.leadingAnchor),
            otherOptionsButton.heightAnchor.constraint(equalToConstant: 40)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
}
