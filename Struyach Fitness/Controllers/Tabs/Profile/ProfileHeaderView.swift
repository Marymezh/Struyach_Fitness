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
        image.layer.cornerRadius = 60
        image.contentMode = .scaleAspectFill
        image.toAutoLayout()
        return image
    }()
    
    let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.text = "Unknown user"
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.toAutoLayout()
        return label
    }()
    
    let userEmailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        label.textColor = .white
        label.numberOfLines = 0
        label.sizeToFit()
        label.toAutoLayout()
        return label
    }()
    
    lazy var changeUserNameButton: UIButton = {
        let button = UIButton()
        button.setTitle("Rename user", for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.toAutoLayout()
        return button
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.toAutoLayout()
        return stackView
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
        self.addSubviews(userPhotoImage, stackView)
        self.stackView.addArrangedSubview(userNameLabel)
        self.stackView.addArrangedSubview(userEmailLabel)
        self.stackView.addArrangedSubview(changeUserNameButton)
                    

        let constraints = [
            userPhotoImage.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: baseInset),
            userPhotoImage.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: baseInset),
            userPhotoImage.heightAnchor.constraint(equalToConstant: 120),
            userPhotoImage.widthAnchor.constraint(equalTo: userPhotoImage.heightAnchor),
            userPhotoImage.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -baseInset*2),
            
            changeUserNameButton.heightAnchor.constraint(equalToConstant: 30),
            stackView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: baseInset),
            stackView.leadingAnchor.constraint(equalTo: userPhotoImage.trailingAnchor, constant: baseInset),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -baseInset*2),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -baseInset*2)
   ]
   
        NSLayoutConstraint.activate(constraints)
    }
}
