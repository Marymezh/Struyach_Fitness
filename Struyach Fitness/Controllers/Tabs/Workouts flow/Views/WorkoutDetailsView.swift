//
//  WorkoutDetailsView.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 21/4/23.
//

import UIKit

class WorkoutDetailsView: UIView {
    
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
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.cornerRadius = 10
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowRadius = 10
        view.layer.shadowOffset = CGSize(width: 5, height: 5)
        view.layer.shadowOpacity = 0.7
        view.alpha = 0.8
        return view
    }()
    
    let detailsView: UITextView = {
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
        secondContainerView.addSubview(detailsView)
        
        let constraints = [
            containerView.topAnchor.constraint(equalTo: self.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            secondContainerView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            secondContainerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            secondContainerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            secondContainerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
            
            detailsView.topAnchor.constraint(equalTo: secondContainerView.topAnchor, constant: 10),
            detailsView.leadingAnchor.constraint(equalTo: secondContainerView.leadingAnchor, constant: 10),
            detailsView.trailingAnchor.constraint(equalTo: secondContainerView.trailingAnchor, constant: -10),
            detailsView.heightAnchor.constraint(equalToConstant: 130),
            detailsView.bottomAnchor.constraint(equalTo: secondContainerView.bottomAnchor, constant: -10)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }

}
