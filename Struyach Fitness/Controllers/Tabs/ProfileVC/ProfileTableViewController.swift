//
//  ProfileTableViewController.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 8/2/23.
//

import UIKit
import IQKeyboardManagerSwift

class ProfileTableViewController: UITableViewController {
    
    private let movements = ["", "Back Squat", "Front Squat", "Squat Clean", "Power Clean", "Clean and Jerk", "Snatch", "Deadlift"]
    
    private var weights = ["", "00", "00", "00", "00", "00", "00", "00"]
    private let headerView = ProfileHeaderView()

    
    let currentEmail: String

    init(currentEmail: String) {
        self.currentEmail = currentEmail
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
        uploadUserRecords()
    }
    
    private func setupTableView() {
        tableView.backgroundColor = .customDarkGray
        tableView.register(ProfileTableViewCell.self, forCellReuseIdentifier: String(describing: ProfileTableViewCell.self))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CellID")
    }
    
    private func setupHeaderView() {
        headerView.isUserInteractionEnabled = true
        headerView.userPhotoImage.isUserInteractionEnabled = true
        setupGuestureRecognizer()
    }
    
    private func setupGuestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(userPhotoImageTapped))
        headerView.userPhotoImage.addGestureRecognizer(tap)
    }
    
    @objc private func userPhotoImageTapped() {
       guard let myEmail = UserDefaults.standard.string(forKey: "email"),
             myEmail == currentEmail else {return}
        showImagePickerController()
    }
    
    func fetchProfileData() {
        DatabaseManager.shared.getUser(email: currentEmail) { [weak self] user in
            guard let user = user else {return}
            DispatchQueue.main.async {
                self?.headerView.userNameLabel.text = user.name
                UserDefaults.standard.set(user.name, forKey: "userName")
                self?.headerView.userEmailLabel.text = user.email
                guard let ref = user.profilePictureRef else {return}
                StorageManager.shared.downloadUrlForProfilePicture(path: ref) { url in
                    guard let url = url else {return}
                    let task = URLSession.shared.dataTask(with: url) { data, _, _ in
                        guard let data = data else {return}
                        let encoded = try! PropertyListEncoder().encode(data)
                        UserDefaults.standard.set(encoded, forKey: "userImage")
                        DispatchQueue.main.async {
                            self?.headerView.userPhotoImage.image = UIImage(data: data)
                            
                        }
                    }
                    task.resume()
                }
            }
        }
    }
    
    func fetchUserRecords() {
        DatabaseManager.shared.getUser(email: currentEmail) { [weak self] user in
            guard let user = user, let self = self else {return}
            guard let ref = user.personalRecords else {return}
            StorageManager.shared.downloadUrlForUserRecords(path: ref) { url in
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
        StorageManager.shared.uploadUserPersonalRecords(email: self.currentEmail, weights: self.weights) { [weak self] success in
            guard let self = self else {return}
            if success {
                DatabaseManager.shared.updateUserPersonalRecords(email: self.currentEmail) { success in
                    guard success else {return}
                    print ("Records are updated")
                }
            }
        }
    }

   private func setupNavigationBar () {
       navigationController?.navigationBar.tintColor = .systemRed
       navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 30, weight: .bold)]
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
                        signInVC.navigationItem.largeTitleDisplayMode = .always
                        let navVC = UINavigationController(rootViewController: signInVC)
                        navVC.navigationBar.prefersLargeTitles = true
                        navVC.modalPresentationStyle = .fullScreen
                        self?.present(navVC, animated: true)
                    }
                }
            }
        }))
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
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.font = UIFont.systemFont(ofSize: 22, weight: .bold)
            return cell
        default:
            let cell: ProfileTableViewCell = tableView.dequeueReusableCell(withIdentifier: String(describing: ProfileTableViewCell.self), for: indexPath) as! ProfileTableViewCell
            
            cell.backgroundColor = .customLightGray
            cell.movementLabel.text = movements[indexPath.row]
            cell.weightLabel.text = "\(weights[indexPath.row]) kg"
            cell.weightIsSet = { [weak self] text in
                guard let self = self else {return}
                self.weights.remove(at: indexPath.row)
                self.weights.insert(text, at: indexPath.row)
                self.tableView.reloadData()

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
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return UITableView.automaticDimension
    }
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        navigationController?.dismiss(animated: true)
        
        guard let image = info[.editedImage] as? UIImage else { return }
        self.headerView.userPhotoImage.image = image
        
        StorageManager.shared.uploadUserProfilePicture(email: currentEmail, image: image) { [weak self] success in
            guard let self = self else {return}
            if success {
                DatabaseManager.shared.updateProfilePhoto(email: self.currentEmail) { success in
                    guard success else {return}
                    DispatchQueue.main.async {
                        self.fetchProfileData()
                    }
                }
            }
        }
    }
}
