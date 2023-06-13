//
//  ActivityView.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 21/4/23.
//

import UIKit

final class ActivityView: UIView {
    
    //MARK: - Properties
    
    let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.7
        view.toAutoLayout()
        return view
    }()
    
   let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.toAutoLayout()
        indicator.color = .systemGreen
        return indicator
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
    
    private func setupSubviews()  {
        self.addSubviews(backgroundView, activityIndicator)
        
        let constraints = [
            backgroundView.topAnchor.constraint(equalTo: self.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func showActivityIndicator() {
        self.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hide() {
        self.isHidden = true
        activityIndicator.stopAnimating()
    }

}
