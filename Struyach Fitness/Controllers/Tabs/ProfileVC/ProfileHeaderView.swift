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
    
    var currentUserEmail = UserDefaults.standard.string(forKey: "email")
    
    var profilePhoto: String?
    
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
        label.toAutoLayout()
        return label
    }()
    
    private let userEmailLabel: UILabel = {
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
        setupGuestureRecognizer()
        fetchProfileData()
    }
    
    private func setupUI () {
        self.backgroundColor = .systemTeal
        userPhotoImage.isUserInteractionEnabled = true
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
    
    private func setupGuestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(userPhotoImageTapped))
        userPhotoImage.addGestureRecognizer(tap)
    }
    
    @objc private func userPhotoImageTapped() {
        //TODO: - May be later: when show other users profiles do not allow to change their user photo
        showImagePickerController()
    }
    
    private func fetchProfileData() {
        guard let email = currentUserEmail else {return}
        DatabaseManager.shared.getUser(email: email) { [weak self] user in
            guard let user = user else {return}
            DispatchQueue.main.async {
                self?.userNameLabel.text = user.name
                self?.userEmailLabel.text = user.email
                guard let ref = user.profilePictureRef else {return}
                StorageManager.shared.downloadUrlForProfilePicture(path: ref) { url in
                    guard let url = url else {return}
                    let task = URLSession.shared.dataTask(with: url) { data, _, _ in
                        guard let data = data else {return}
                        DispatchQueue.main.async {
                            self?.userPhotoImage.image = UIImage(data: data)
                        }
                    }
                    task.resume()
                }
            }
        }
    }
//
//    private func loadImage() {
//        guard let data = UserDefaults.standard.data(forKey: "userImage") else {return}
//        let decoded = try! PropertyListDecoder().decode(Data.self, from: data)
//        let image = UIImage(data: decoded)
//        self.userPhotoImage.image = image
//    }
    
    private func showErrorAlert(text: String) {
        let alert = UIAlertController(title: "Error", message: text, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.view.tintColor = .red
        alert.addAction(cancelAction)
        self.window?.rootViewController?.present(alert, animated: true)
    }
}

extension ProfileHeaderView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private func showImagePickerController() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        picker.sourceType = .photoLibrary
        self.window?.rootViewController?.present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.window?.rootViewController?.dismiss(animated: true)
        
        guard let image = info[.editedImage] as? UIImage,
        let email = currentUserEmail else { return }
//        self.userPhotoImage.image = image
        
        StorageManager.shared.uploadUserProfilePicture(email: email, image: image) { [weak self] success in
            guard let self = self else {return}
            if success {
                DatabaseManager.shared.updateProfilePhoto(email: email) { success in
                    guard success else {return}
                    DispatchQueue.main.async {
                        self.fetchProfileData()
                    }
                }
            }
        }
        
        guard let data = image.jpegData(compressionQuality: 0.5) else {return}
        let encoded = try! PropertyListEncoder().encode(data)
        UserDefaults.standard.set(encoded, forKey: "userImage")
    }
}
