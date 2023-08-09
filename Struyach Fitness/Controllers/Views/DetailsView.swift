//
//  DetailsView.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 21/4/23.
//

import UIKit

final class DetailsView: UIView {
    
    //MARK: - Properties
    
    let containerView: UIView = {
        let view = UIView()
        view.toAutoLayout()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }()
    
    let textView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .systemGray6
        textView.isScrollEnabled = true
        textView.isUserInteractionEnabled = true
        textView.isEditable = false
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.toAutoLayout()
        return textView
    }()
    
    //MARK: - Lifecycle

    init() {
           super.init(frame: .zero)
        setupSubviews() 
       }

       required init?(coder: NSCoder) {
           fatalError("init(coder:) has not been implemented")
       }
    
    private func setupSubviews() {
        self.addSubview(containerView)
        containerView.addSubview(textView)
        
        let constraints = [
            containerView.topAnchor.constraint(equalTo: self.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            textView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            textView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            textView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            textView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
}
