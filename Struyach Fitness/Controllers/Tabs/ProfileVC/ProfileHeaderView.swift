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
//        image.layer.borderColor = UIColor.black.cgColor
//        image.layer.borderWidth = 0.5
        image.layer.cornerRadius = 60
        image.layer.shadowColor = UIColor.darkGray.cgColor
        image.layer.shadowRadius = 60
        image.layer.shadowOffset = CGSize(width: 5, height: 5)
        image.layer.shadowOpacity = 0.6
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
        label.sizeToFit()
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
        button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.layer.shadowColor = UIColor.darkGray.cgColor
        button.layer.shadowRadius = 5
        button.layer.shadowOffset = CGSize(width: 5, height: 5)
        button.layer.shadowOpacity = 0.6
     //   button.addTarget(self, action: #selector(changeName), for: .touchUpInside)
        button.toAutoLayout()
        return button
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .equalSpacing
        stackView.axis = .vertical
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
            
            stackView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 5),
            stackView.leadingAnchor.constraint(equalTo: userPhotoImage.trailingAnchor, constant: baseInset),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -baseInset*2),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -baseInset*2)
   ]
   
        NSLayoutConstraint.activate(constraints)
    }
    
//    @objc func changeName () {
//        let alertController = UIAlertController(title: "Change user name", message: nil, preferredStyle: .alert)
//        alertController.addTextField { textfield in
//            textfield.placeholder = "Enter new name here"
//        }
//        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
//        let changeAction = UIAlertAction(title: "Save", style: .default) { action in
//            if let text = alertController.textFields?[0].text,
//               text != "" {
//                UserDefaults.standard.set(text, forKey: "userName")
//                self.userNameLabel.text = text
//            } else {
//                self.showErrorAlert(text: "User name can not be blank!")
//            }
//        }
//        
//        alertController.addAction(changeAction)
//        alertController.addAction(cancelAction)
//
//        alertController.view.tintColor = .darkGray
//        self.window?.rootViewController?.present(alertController, animated: true)
//        
//    }
    
    private func showErrorAlert(text: String) {
        let alert = UIAlertController(title: "Error", message: text, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.view.tintColor = .red
        alert.addAction(cancelAction)
        self.window?.rootViewController?.present(alert, animated: true)
    }


}
