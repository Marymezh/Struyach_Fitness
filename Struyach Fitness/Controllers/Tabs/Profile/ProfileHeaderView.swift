//
//  ProfileHeaderView.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 8/2/23.
//

import UIKit
import SwiftUI


final class ProfileHeaderView: UIView {
    
    //MARK: - Properties
    
    private var baseInset: CGFloat { return 15 }
    
    let userPhotoImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(systemName: "person.circle")
        image.tintColor = .white
        image.clipsToBounds = true
        image.layer.cornerRadius = 50
        image.contentMode = .scaleAspectFill
        image.toAutoLayout()
        return image
    }()
    
    let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.text = "Unknown user".localized()
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
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.textColor = .white
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.sizeToFit()
        label.toAutoLayout()
        return label
    }()
    

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalCentering
        stackView.alignment = .center
        stackView.spacing = 15
        stackView.toAutoLayout()
        return stackView
    }()

    //MARK: - Lifecycle
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    //MARK: - Methods
    
    private func setupUI () {
        self.backgroundColor = .customDarkGray
        self.addSubviews(userPhotoImage, stackView)
        self.stackView.addArrangedSubview(userNameLabel)
        self.stackView.addArrangedSubview(userEmailLabel)

        let constraints = [
            userPhotoImage.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            userPhotoImage.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: baseInset),
            userPhotoImage.heightAnchor.constraint(equalToConstant: 100),
            userPhotoImage.widthAnchor.constraint(equalTo: userPhotoImage.heightAnchor),
            userPhotoImage.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -baseInset),

            stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: userPhotoImage.trailingAnchor, constant: baseInset),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -baseInset*2),
   ]
   
        NSLayoutConstraint.activate(constraints)
    }
}
