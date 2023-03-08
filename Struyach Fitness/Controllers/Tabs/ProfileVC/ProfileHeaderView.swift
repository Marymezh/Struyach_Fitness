//
//  ProfileHeaderView.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 8/2/23.
//

import UIKit
import SwiftUI


class ProfileHeaderView: UIView {
    
    private var baseInset: CGFloat { return 15 }
    
    let userPhotoImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "general")
        image.clipsToBounds = true
        image.layer.cornerRadius = 40
        image.contentMode = .scaleAspectFill
        image.layer.borderColor = UIColor.darkGray.cgColor 
        image.layer.borderWidth = 3
        image.toAutoLayout()
        return image
    }()
    
    let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.text = "Unknown user"
        label.textColor = .white
        label.textAlignment = .left
        label.numberOfLines = 0
        label.sizeToFit()
        label.toAutoLayout()
        return label
    }()
    
    let userEmailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .left
        label.textColor = .white
        label.numberOfLines = 0
        label.sizeToFit()
        label.toAutoLayout()
        return label
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    private func setupUI () {
        self.backgroundColor = .customDarkGray
        self.addSubviews(userPhotoImage, userNameLabel, userEmailLabel)
        
        let constraints = [
            userPhotoImage.topAnchor.constraint(equalTo: self.topAnchor, constant: baseInset),
            userPhotoImage.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: baseInset),
            userPhotoImage.heightAnchor.constraint(equalToConstant: 80),
            userPhotoImage.widthAnchor.constraint(equalTo: userPhotoImage.heightAnchor),
            userPhotoImage.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -baseInset),
            
            userNameLabel.bottomAnchor.constraint(equalTo: userPhotoImage.centerYAnchor, constant: -5),
            userNameLabel.leadingAnchor.constraint(equalTo: userPhotoImage.trailingAnchor, constant: baseInset*3),
            userNameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -baseInset),
            
            userEmailLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 10),
            userEmailLabel.leadingAnchor.constraint(equalTo: userNameLabel.leadingAnchor),
            userEmailLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -baseInset)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
}
