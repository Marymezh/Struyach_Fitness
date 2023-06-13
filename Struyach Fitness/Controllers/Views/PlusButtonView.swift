//
//  PlusButtonView.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 28/4/23.
//

import UIKit

class PlusButtonView: UIView {

    let plusButton: UIButton = {
       let button = UIButton()
        button.setImage(UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .medium)), for: .normal)
        button.backgroundColor = .systemGreen
        button.tintColor = .white
        button.layer.cornerRadius = 30
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowRadius = 30
        button.layer.shadowOffset = CGSize(width: 5, height: 5)
        button.layer.shadowOpacity = 0.6
        button.clipsToBounds = false
        button.toAutoLayout()
        return button
    }()
    
    //MARK: - Lifecycle
    
    init() {
        super.init(frame: .zero)
        setupSubviews()
        self.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        self.addSubview(plusButton)
        
        let constraints = [
            plusButton.topAnchor.constraint(equalTo: self.topAnchor),
            plusButton.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            plusButton.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            plusButton.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }

}
