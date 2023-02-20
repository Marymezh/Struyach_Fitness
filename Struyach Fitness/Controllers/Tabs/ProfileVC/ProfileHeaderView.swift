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
    
  //var currentUserEmail = UserDefaults.standard.string(forKey: "email")

 //   var profilePhoto: String?
    
    let userPhotoImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "general")
        image.clipsToBounds = true
        image.layer.cornerRadius = 60
        image.contentMode = .scaleAspectFill
        image.layer.borderColor = UIColor.black.cgColor
        image.layer.borderWidth = 0.5
        image.toAutoLayout()
        return image
    }()
    
    let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textColor = .black
        label.text = "Unknown user"
        label.textAlignment = .left
        label.numberOfLines = 0
        label.sizeToFit()
        label.toAutoLayout()
        return label
    }()
    
    let userEmailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.textColor = .black
        label.textAlignment = .left
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
        self.backgroundColor = .systemTeal
        self.addSubviews(userPhotoImage, userNameLabel, userEmailLabel)
        
        let constraints = [
            userPhotoImage.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            userPhotoImage.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: baseInset),
            userPhotoImage.heightAnchor.constraint(equalToConstant: 120),
            userPhotoImage.widthAnchor.constraint(equalTo: userPhotoImage.heightAnchor),
            userPhotoImage.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -baseInset*2),
            
            userNameLabel.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: baseInset),
            userNameLabel.leadingAnchor.constraint(equalTo: userPhotoImage.trailingAnchor, constant: baseInset*3),
            userNameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -baseInset),
            
            userEmailLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: baseInset),
            userEmailLabel.leadingAnchor.constraint(equalTo: userNameLabel.leadingAnchor),
            userEmailLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -baseInset)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}