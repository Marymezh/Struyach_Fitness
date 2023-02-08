//
//  ProfileHeaderView.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 8/2/23.
//

import UIKit

enum Mode {
    case unkonwnUser
    case currentUser
}

class ProfileHeaderView: UIView {
    
    private var baseInset: CGFloat { return 15 }
    
    var onNameChanged:(()-> Void)?
    
    var mode: Mode?
    
    private var userName: String {
        switch mode {
        case .unkonwnUser:
            return "Unknown User"
        case .currentUser:
            return UserDefaults.standard.object(forKey: "userName") as? String ?? ""
        default:
            return ""
        }
    }
    
    private var buttonTitle: String {
        switch mode {
        case .unkonwnUser:
            return "Set user name"
        case.currentUser:
            return "Change user name"
        default:
            return ""
        }
    }
    
    private let userPhotoImage: UIImageView = {
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
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textColor = .black
        label.textAlignment = .left
        label.numberOfLines = 0
        label.sizeToFit()
        label.text = "Unknown User"
        label.toAutoLayout()
        return label
    }()
    
    private lazy var changeImageButton: UIButton = {
        let button = UIButton()
        button.setTitle("Change photo", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .darkGray
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(changePhoto), for: .touchUpInside)
        button.toAutoLayout()
        return button
    }()
    
    @objc func changePhoto() {
        showImagePickerController()
    }
    
    private lazy var changeUserNameButton: UIButton = {
        let button = UIButton()
        button.setTitle("Set user name", for: .normal)
        button.backgroundColor = .darkGray
        button.setTitleColor(.white, for: .normal)
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(changeName), for: .touchUpInside)
        button.toAutoLayout()
        return button
    }()
    
    @objc func changeName () {
        let alertController = UIAlertController(title: "Change user name", message: nil, preferredStyle: .alert)
        alertController.addTextField { textfield in
            textfield.placeholder = "Enter new name here"
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        let changeAction = UIAlertAction(title: "Save", style: .default) { action in
            if let text = alertController.textFields?[0].text,
               text != "" {
                UserDefaults.standard.set(text, forKey: "userName")
                self.mode = .currentUser
                self.userNameLabel.text = self.userName
                self.changeUserNameButton.setTitle(self.buttonTitle, for: .normal)
                self.onNameChanged?()
            } else {
                self.showErrorAlert(text: "User name can not be blank!")
            }
        }
        
        alertController.addAction(changeAction)
        alertController.addAction(cancelAction)

        alertController.view.tintColor = .darkGray
        self.window?.rootViewController?.present(alertController, animated: true)
        
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        setNewUserNameMode()
        setupUI()
    }
    
    private func setNewUserNameMode() {
        if let text = UserDefaults.standard.object(forKey: "userName") as? String {
            if text != "" {
                mode = .currentUser
                changeUserNameButton.setTitle(buttonTitle, for: .normal)
                userNameLabel.text = userName
                loadImage() 
            }
        }
    }
    
    private func setupUI () {
        self.backgroundColor = .systemTeal
        self.addSubviews(userPhotoImage, userNameLabel, changeUserNameButton, changeImageButton)
        
        let constraints = [
        
            userPhotoImage.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: baseInset),
            userPhotoImage.heightAnchor.constraint(equalToConstant: 120),
            userPhotoImage.widthAnchor.constraint(equalTo: userPhotoImage.heightAnchor),
            userPhotoImage.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -baseInset*2),

            userNameLabel.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            userNameLabel.leadingAnchor.constraint(equalTo: userPhotoImage.trailingAnchor, constant: baseInset),
            userNameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -baseInset),
            
            changeImageButton.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: baseInset),
            changeImageButton.leadingAnchor.constraint(equalTo: userPhotoImage.trailingAnchor, constant: baseInset),
            changeImageButton.heightAnchor.constraint(equalToConstant: 35),
            changeImageButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -baseInset),
            
            changeUserNameButton.topAnchor.constraint(equalTo: changeImageButton.bottomAnchor, constant: baseInset),
            changeUserNameButton.leadingAnchor.constraint(equalTo: changeImageButton.leadingAnchor),
            changeUserNameButton.trailingAnchor.constraint(equalTo: changeImageButton.trailingAnchor),
            changeUserNameButton.heightAnchor.constraint(equalTo: changeImageButton.heightAnchor),
            changeUserNameButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -baseInset*2)

        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func loadImage() {
        guard let data = UserDefaults.standard.data(forKey: "userImage") else {return}
        let decoded = try! PropertyListDecoder().decode(Data.self, from: data)
        let image = UIImage(data: decoded)
        self.userPhotoImage.image = image
    }
    
    private func showErrorAlert(text: String) {
        let alert = UIAlertController(title: "Error", message: text, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.view.tintColor = .red
        alert.addAction(cancelAction)
        self.window?.rootViewController?.present(alert, animated: true)
    }
    
    
}

extension ProfileHeaderView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
        func showImagePickerController() {
            let picker = UIImagePickerController()
            picker.allowsEditing = true
            picker.delegate = self
            picker.sourceType = .photoLibrary
            self.window?.rootViewController?.present(picker, animated: true)
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            self.window?.rootViewController?.dismiss(animated: true)
            
            guard let image = info[.editedImage] as? UIImage else { return }
            self.userPhotoImage.image = image
            guard let data = image.jpegData(compressionQuality: 0.5) else {return}
            let encoded = try! PropertyListEncoder().encode(data)
            UserDefaults.standard.set(encoded, forKey: "userImage")
        }
}
