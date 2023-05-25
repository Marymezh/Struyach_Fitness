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
        view.backgroundColor = .customDarkComments
        return view
    }()
    
    let secondContainerView: UIView = {
        let view = UIView()
        view.toAutoLayout()
        view.backgroundColor = .systemGray6
//        view.layer.borderWidth = 0.5
//        view.layer.borderColor = UIColor.black.cgColor
//        view.layer.cornerRadius = 10
//        view.layer.shadowColor = UIColor.black.cgColor
//        view.layer.shadowRadius = 10
//        view.layer.shadowOffset = CGSize(width: 5, height: 5)
//        view.layer.shadowOpacity = 0.7
        view.alpha = 0.8
        return view
    }()
    
    let textView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .systemGray6
        textView.isScrollEnabled = true
        textView.isUserInteractionEnabled = true
        textView.isEditable = false
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.layer.cornerRadius = 10
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
        containerView.addSubview(secondContainerView)
        secondContainerView.addSubview(textView)
        
        let constraints = [
            containerView.topAnchor.constraint(equalTo: self.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            secondContainerView.topAnchor.constraint(equalTo: containerView.topAnchor),
            secondContainerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            secondContainerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            secondContainerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            textView.topAnchor.constraint(equalTo: secondContainerView.topAnchor, constant: 10),
            textView.leadingAnchor.constraint(equalTo: secondContainerView.leadingAnchor, constant: 10),
            textView.trailingAnchor.constraint(equalTo: secondContainerView.trailingAnchor, constant: -10),
            textView.heightAnchor.constraint(equalToConstant: 150),
            textView.bottomAnchor.constraint(equalTo: secondContainerView.bottomAnchor, constant: -10)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }

}
