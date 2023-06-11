//
//  ProfileTableViewController.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 8/2/23.
//

import UIKit

final class ProfileTableViewController: UITableViewController {
    
    //MARK: - Properties
    
    private let movements = ["", "Back Squat", "Front Squat", "Squat Clean", "Power Clean", "Clean and Jerk", "Snatch", "Deadlift"]
    
    private var weights = ["", "00", "00", "00", "00", "00", "00", "00"]
    private let headerView = ProfileHeaderView()
    private let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    let email: String
    let currentUserEmail = UserDefaults.standard.string(forKey: "email")

    //MARK: - Lifecycle
    
    init(email: String) {
        self.email = email
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupHeaderView()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchProfileData()
        

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if currentUserEmail == email {
            uploadUserRecords()
        }
    }
    
    deinit {
           print ("profile vc is deallocated")
       }
    
    //MARK: - Setup methods
    private func setupTableView() {
        tableView.backgroundColor = .customDarkGray
        tableView.register(ProfileTableViewCell.self, forCellReuseIdentifier: ProfileTableViewCell.reuseIdentifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CellID")
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30)
        tableView.separatorColor = .black
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
    
    //MARK: - Buttons methods
    
    @objc private func userPhotoImageTapped() {
        guard currentUserEmail == email else {return}
        showImagePickerController()
    }
    
    //MARK: - Fetch and update data methods
    
    func fetchOtherUserData(completion: @escaping (Bool)->()) {
        DatabaseManager.shared.getUser(email: email) { [weak self] user in
            guard let self = self, let user = user else { return }
            let imageRef = user.profilePictureRef
            StorageManager.shared.downloadUrl(path: imageRef) { url in
                guard let url = url else { return }

                let task = URLSession.shared.dataTask(with: url) { data, response, error in
                    guard let data = data, error == nil else {
                        print("Error downloading image: \(error?.localizedDescription ?? "unknown error".localized())")
                        return
                    }

                    if let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self.headerView.userPhotoImage.image = image
                            self.headerView.userNameLabel.text = user.name
                            self.headerView.userEmailLabel.text = user.email
                            self.headerView.userEmailLabel.isHidden = user.emailIsHidden ? true : false
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
                self.headerView.userEmailLabel.isHidden = user.emailIsHidden ? true : false
            }
        }
    }
    
    func fetchUserRecords() {
        print ("fetching user recods func is running")
        DatabaseManager.shared.getUser(email: email) { [weak self] user in
            guard let user = user,
                  let self = self,
                  let ref = user.personalRecords else {return}
            StorageManager.shared.downloadUrl(path: ref) { url in
                guard let url = url else {return}
                
                let task = URLSession.shared.dataTask(with: url) { data, _, _ in
                    guard let data = data else {return}
                    self.weights = try! JSONDecoder().decode([String].self, from: data)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
                task.resume()
            }
        }
    }
    
    private func uploadUserRecords() {
        // upload saved weights array to Firebase Storage
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

    // MARK: - Table view data source
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return movements.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellID", for: indexPath)
            cell.backgroundColor = .customDarkGray
            cell.selectionStyle = .none
            cell.textLabel?.text = "Personal Records".localized()
            cell.textLabel?.textColor = .white
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
            return cell
        default:
            let cell: ProfileTableViewCell = tableView.dequeueReusableCell(withIdentifier: ProfileTableViewCell.reuseIdentifier, for: indexPath) as! ProfileTableViewCell
            if indexPath.row == 1 {
                cell.containerView.layer.cornerRadius = 15
                cell.containerView.layer.masksToBounds = true
                cell.containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            } else if indexPath.row == tableView.numberOfRows(inSection: indexPath.section)-1 {
                cell.containerView.layer.cornerRadius = 15
                cell.containerView.layer.masksToBounds = true
                cell.containerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            } else {
                cell.containerView.layer.cornerRadius = 0
            }
            cell.movementLabel.text = movements[indexPath.row]
            cell.weightLabel.text = String(format: "%@ kg".localized(), weights[indexPath.row])
            cell.weightIsSet = { [weak self] text in
                guard let self = self else {return}
                self.weights.remove(at: indexPath.row)
                self.weights.insert(text, at: indexPath.row)
                self.tableView.reloadData()
            }
            
            if email != currentUserEmail {
                cell.weightTextField.isHidden = true
                cell.saveButton.isHidden = true
            }
                
            
//            if email == currentUserEmail {
//                cell.movementLabel.text = movements[indexPath.row]
//                cell.weightLabel.text = String(format: "%@ kg".localized(), weights[indexPath.row])
//                cell.weightIsSet = { [weak self] text in
//                    guard let self = self else {return}
//                    self.weights.remove(at: indexPath.row)
//                    self.weights.insert(text, at: indexPath.row)
//    //                self.tableView.reloadData()
//                }
//            } else {
//                cell.movementLabel.text = movements[indexPath.row]
//                cell.weightLabel.text = String(format: "%@ kg".localized(), weights[indexPath.row])
//                cell.weightTextField.isHidden = true
//                cell.saveButton.isHidden = true
//            }
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerView
    }
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        return footerView
    }
}

//MARK: - UIImagePickerControllerDelegate methods
extension ProfileTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private func showImagePickerController() {
        let picker = UIImagePickerController()
        picker.navigationBar.tintColor = UIColor.systemGreen
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
