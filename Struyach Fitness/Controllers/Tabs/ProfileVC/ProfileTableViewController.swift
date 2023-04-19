//
//  ProfileTableViewController.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 8/2/23.
//

import UIKit
//import IQKeyboardManagerSwift

class ProfileTableViewController: UITableViewController {
    
    private let movements = ["", "Back Squat", "Front Squat", "Squat Clean", "Power Clean", "Clean and Jerk", "Snatch", "Deadlift"]
    
    private var weights = ["", "00", "00", "00", "00", "00", "00", "00"]
    private let headerView = ProfileHeaderView()
    private let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    let email: String
    let currentUserEmail = UserDefaults.standard.string(forKey: "email")

    init(email: String) {
        self.email = email
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
        setupHeaderView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if currentUserEmail == email {
            uploadUserRecords()
        }
    }
    
    private func setupTableView() {
        tableView.backgroundColor = .customDarkGray
        tableView.register(ProfileTableViewCell.self, forCellReuseIdentifier: String(describing: ProfileTableViewCell.self))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CellID")
//        tableView.estimatedSectionHeaderHeight = 165
//        tableView.sectionHeaderHeight = UITableView.automaticDimension
    }
    
    private func setupHeaderView() {
        headerView.isUserInteractionEnabled = true
        headerView.userPhotoImage.isUserInteractionEnabled = true
        setupGuestureRecognizer()
    }
    
    private func setupGuestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(userPhotoImageTapped))
        headerView.userPhotoImage.addGestureRecognizer(tap)
        
        let buttonTap = UITapGestureRecognizer(target: self, action: #selector(changeUserNameTapped))
        headerView.changeUserNameButton.addGestureRecognizer(buttonTap)
    }
    
    @objc private func userPhotoImageTapped() {
        guard currentUserEmail == email else {return}
        showImagePickerController()
    }
    
    @objc private func changeUserNameTapped() {
        let alertController = UIAlertController(title: "Change user name", message: nil, preferredStyle: .alert)
        alertController.addTextField { textfield in
            textfield.placeholder = "Enter new name here"
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        let changeAction = UIAlertAction(title: "Save", style: .default) { action in
            if let text = alertController.textFields?[0].text,
               text != "" {
                UserDefaults.standard.set(text, forKey: "userName")
                self.headerView.userNameLabel.text = text
                DatabaseManager.shared.updateUserName(email: self.email, newUserName: text) { success in
                    if success {
                        DispatchQueue.main.async {
                            self.headerView.userNameLabel.text = text
                        }
                    }
                }
            } else {
                self.showErrorAlert(text: "User name can not be blank!")
            }
        }
        
        alertController.addAction(changeAction)
        alertController.addAction(cancelAction)

        alertController.view.tintColor = .darkGray
        present(alertController, animated: true)
    }
    
    func fetchOtherUserData(completion: @escaping (Bool)->()) {
        DatabaseManager.shared.getUser(email: email) { [weak self] user in
            guard let self = self, let user = user else { return }
            let imageRef = user.profilePictureRef
            StorageManager.shared.downloadUrl(path: imageRef) { url in
                guard let url = url else { return }

                let task = URLSession.shared.dataTask(with: url) { data, response, error in
                    guard let data = data, error == nil else {
                        print("Error downloading image: \(error?.localizedDescription ?? "unknown error")")
                        return
                    }

                    if let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self.headerView.userPhotoImage.image = image
                            self.headerView.userNameLabel.text = user.name
                            self.headerView.userEmailLabel.text = user.email
                            completion(true)
                        }
                    } else {
                        print("Error creating image from data")
                    }
                }
                task.resume()
            }
        }
    }
    
    func fetchProfileData() {
        DatabaseManager.shared.getUser(email: email) { [weak self] user in
            guard let self = self, let user = user else { return }
            let imageRef = user.profilePictureRef
            StorageManager.shared.downloadUrl(path: imageRef) { url in
                guard let url = url else {return}
                let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                    guard let data = data, error == nil else { return }
                    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let fileURL = documentsDirectory.appendingPathComponent("userImage.jpg")
                    do {
                        try data.write(to: fileURL)
                        let userImage = UIImage(contentsOfFile: fileURL.path)
                        DispatchQueue.main.async {
                            self.headerView.userPhotoImage.image = userImage
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                task.resume()
            }
            DispatchQueue.main.async {
                self.headerView.userNameLabel.text = user.name
                UserDefaults.standard.set(user.name, forKey: "userName")
                self.headerView.userEmailLabel.text = user.email
            }
        }
    }
    
    func fetchUserRecords() {
        DatabaseManager.shared.getUser(email: email) { [weak self] user in
            guard let user = user, let self = self else {return}
            guard let ref = user.personalRecords else {return}
            StorageManager.shared.downloadUrl(path: ref) { url in
                guard let url = url else {return}
                
                let task = URLSession.shared.dataTask(with: url) { data, _, _ in
                    guard let data = data else {return}
                    self.weights = try! JSONDecoder().decode([String].self, from: data)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    print(self.weights)
                }
                task.resume()
            }
        }
    }
    
    private func uploadUserRecords() {
        // upload saved weights array to Firebase
        StorageManager.shared.uploadUserPersonalRecords(email: self.email, weights: self.weights) { [weak self] success in
            guard let self = self else {return}
            if success {
                DatabaseManager.shared.updateUserPersonalRecords(email: self.email) { success in
                    guard success else {return}
                    print ("Records are updated")
                }
            }
        }
    }

   private func setupNavigationBar () {
       navigationController?.navigationBar.tintColor = .systemRed
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Sign Out",
            style: .done,
            target: self,
            action: #selector(didTapSignOut))
    }
    
    @objc private func didTapSignOut() {
        let alert = UIAlertController(title: "Sign Out", message: "Are you sure you would like to sign out?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { action in
            AuthManager.shared.signOut { [weak self] success in
                if success {
                    DispatchQueue.main.async {
                        UserDefaults.standard.set(nil, forKey: "userName")
                        UserDefaults.standard.set(nil, forKey: "email")
                        UserDefaults.standard.set(nil, forKey: "userImage")
                        let signInVC = LoginViewController()
                        signInVC.navigationItem.largeTitleDisplayMode = .never
                        let navVC = UINavigationController(rootViewController: signInVC)
                        navVC.navigationBar.prefersLargeTitles = false
                        navVC.modalPresentationStyle = .fullScreen
                        self?.present(navVC, animated: true)
                    }
                }
            }
        }))
        present(alert, animated: true)
    }
    
    private func showErrorAlert(text: String) {
        let alert = UIAlertController(title: "Error", message: text, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.view.tintColor = .red
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return movements.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellID", for: indexPath)
            cell.backgroundColor = .customLightGray
            cell.textLabel?.text = "PERSONAL RECORDS"
            cell.textLabel?.textColor = .customDarkGray
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.font = UIFont.systemFont(ofSize: 22, weight: .bold)
            return cell
        default:
            let cell: ProfileTableViewCell = tableView.dequeueReusableCell(withIdentifier: String(describing: ProfileTableViewCell.self), for: indexPath) as! ProfileTableViewCell
            cell.backgroundColor = .customLightGray
            if email == currentUserEmail {
                cell.movementLabel.text = movements[indexPath.row]
                cell.weightLabel.text = "\(weights[indexPath.row]) kg"
                cell.weightIsSet = { [weak self] text in
                    guard let self = self else {return}
                    self.weights.remove(at: indexPath.row)
                    self.weights.insert(text, at: indexPath.row)
                    self.tableView.reloadData()
                    
                }
            } else {
                cell.movementLabel.text = movements[indexPath.row]
                cell.weightLabel.text = "\(weights[indexPath.row]) kg"
                cell.weightTextField.isHidden = true
                cell.saveButton.isHidden = true
            }
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        return headerView
    }
    
//    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        
//        return 150
//    }
}
//MARK: - UIImagePickerControllerDelegate methods
extension ProfileTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private func showImagePickerController() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        picker.sourceType = .photoLibrary
        navigationController?.present(picker, animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        navigationController?.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        navigationController?.dismiss(animated: true)
        guard let image = info[.editedImage] as? UIImage,
        let imageData = image.jpegData(compressionQuality: 0.5) else { return }
        
        self.headerView.userPhotoImage.image = image
        
        StorageManager.shared.setUserProfilePicture(email: email, image: imageData) { [weak self] imageRef in
            guard let self = self, let imageRef = imageRef else {return}
            DatabaseManager.shared.updateProfilePhoto(email: self.email) { success in
                guard success else {return}
                StorageManager.shared.downloadUrl(path: imageRef) { url in
                    guard let url = url else { return }
                    
                    let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                        guard let data = data, error == nil else { return }
                        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                        let fileURL = documentsDirectory.appendingPathComponent("userImage.jpg")
                        do {
                            try data.write(to: fileURL)
                            print ("New user image is uploaded to Storage and saved to filemanager")
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                    task.resume()
                }
            }
        }
    }
}
