//
//  ProfileTableViewController.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 8/2/23.
//

import UIKit
import Photos

final class ProfileTableViewController: UITableViewController {
    
    //MARK: - Properties
    
    private let movements = ["", "Back Squat".localized(), "Front Squat".localized(), "Squat Clean".localized(), "Power Clean".localized(), "Clean and Jerk".localized(), "Squat Snatch".localized(), "Power Snatch".localized(), "Deadlift".localized()]
    private let gymnastics = ["", "Push-ups".localized(), "Pull-ups".localized(), "Muscle-ups".localized(), "Ring muscle-ups".localized(), "Toes-to-bars".localized(), "Double-unders".localized()]
    private var weights = ["", "00", "00", "00", "00", "00", "00", "00", "00"]
    private var reps = ["", "0", "0", "0", "0", "0", "0"]
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
        print ("user tapped on the avatar")
        askForPermission()
    }
    
    //MARK: - Fetch and update data methods
    
    func fetchOtherUserData(completion: @escaping (Bool)->()) {
        DatabaseManager.shared.getUser(email: email) { [weak self] user in
            guard let self = self, let user = user else { return }
            guard let imageRef = user.profilePictureRef else {return}
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
    func fetchUserImage() {
        print ("fetching user image")
        DatabaseManager.shared.getUser(email: email) { [weak self] user in
            guard let self = self, let user = user else { return }
            guard let imageRef = user.profilePictureRef else {return}
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
                        }
                        print ("set user image for the avatar")
                    } else {
                        print("Error creating image from data")
                    }
                }
                task.resume()
            }
        }
    }
    
    func fetchProfileData() {
        print ("fetching profile data for user")
        DatabaseManager.shared.getUser(email: email) { [weak self] user in
            guard let self = self, let user = user else { return }
            DispatchQueue.main.async {
                self.headerView.userNameLabel.text = user.name
                UserDefaults.standard.set(user.name, forKey: "userName")
                self.headerView.userEmailLabel.text = user.email
                self.headerView.userEmailLabel.isHidden = user.emailIsHidden ? true : false
            }
        }
    }
    
    func fetchUserRecords() {
        print("Fetching user records")
        
        let dispatchGroup = DispatchGroup()
        
        DatabaseManager.shared.getUser(email: email) { [weak self] user in
            guard let user = user,
                  let self = self else {
                return
            }
            dispatchGroup.enter()
            
            if let weightliftingRef = user.weightliftingRecords {
                StorageManager.shared.downloadUrl(path: weightliftingRef) { url in
                    guard let url = url else {
                        dispatchGroup.leave()
                        return
                    }
                    let task = URLSession.shared.dataTask(with: url) { data, _, _ in
                        guard let data = data else {
                            dispatchGroup.leave()
                            return
                        }
                        self.weights = try! JSONDecoder().decode([String].self, from: data)
                        dispatchGroup.leave()
                    }
                    
                    task.resume()
                }
            } else {
                dispatchGroup.leave()
            }
            dispatchGroup.enter()
            
            if let gymnasticRef = user.gymnasticRecords {
                StorageManager.shared.downloadUrl(path: gymnasticRef) { url in
                    guard let url = url else {
                        dispatchGroup.leave()
                        return
                    }
                    let task = URLSession.shared.dataTask(with: url) { data, _, _ in
                        guard let data = data else {
                            dispatchGroup.leave()
                            return
                        }
                        self.reps = try! JSONDecoder().decode([String].self, from: data)
                        dispatchGroup.leave()
                    }
                    task.resume()
                }
            } else {
                dispatchGroup.leave()
            }
            dispatchGroup.notify(queue: .main) {
                self.tableView.reloadData()
            }
        }
    }
   
    private func uploadWeightliftingRecords() {
        // upload saved weights array to Firebase Storage
        StorageManager.shared.uploadUserWeightliftingRecords(email: self.email, weights: self.weights) { [weak self] success in
            guard let self = self else {return}
            if success {
                DatabaseManager.shared.updateUserWeightliftingRecords(email: self.email) { success in
                    guard success else {return}
                    print ("Records are updated")
                }
            }
        }
    }
    
    private func uploadGymnasticRecords() {
        // upload saved weights array to Firebase Storage
        StorageManager.shared.uploadUserGymnasticRecords(email: self.email, reps: self.reps) { [weak self] success in
            guard let self = self else {return}
            if success {
                DatabaseManager.shared.updateUserGymnasticRecords(email: self.email) { success in
                    guard success else {return}
                    print ("Records are updated")
                }
            }
        }
    }

    // MARK: - Table view delegate and data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return movements.count
        default: return gymnastics.count
        }
    
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "CellID", for: indexPath)
                cell.backgroundColor = .customDarkGray
                cell.selectionStyle = .none
                cell.textLabel?.text = "Personal Records".localized()
                cell.textLabel?.textColor = .white
                cell.textLabel?.textAlignment = .center
                cell.textLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
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
                cell.weightTextField.placeholder = "00 kg".localized()
                cell.weightTextField.delegate = self
                
                if email != currentUserEmail {
                    cell.weightTextField.isHidden = true
                }
                return cell
            }
        default:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "CellID", for: indexPath)
                cell.backgroundColor = .customDarkGray
                cell.selectionStyle = .none
                cell.textLabel?.text = "Max reps in 1 minute".localized()
                cell.textLabel?.textColor = .white
                cell.textLabel?.textAlignment = .center
                cell.textLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
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
                cell.movementLabel.text = gymnastics[indexPath.row]
                cell.weightLabel.text = String(format: "%@ reps".localized(), reps[indexPath.row])
                cell.weightTextField.delegate = self
                cell.weightTextField.placeholder = "0 reps".localized()
                if email != currentUserEmail {
                    cell.weightTextField.isHidden = true
                }
                return cell
            }
            
        }
      
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0: return headerView
        default: return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0: return UITableView.automaticDimension
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        switch section {
        case 0: return nil
        default:  let footerView = UIView()
            return footerView
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case 0: return 0
        default: return UITableView.automaticDimension
        }
    }
    
}

//MARK: - UIImagePickerControllerDelegate methods
extension ProfileTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private func askForPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            presentImagePicker()
        case .denied, .restricted:
            AlertManager.shared.showAlert(title: "Permission Denied".localized(), message: "Please allow access to the photo library in Phone Settings to choose an avatar.".localized(), cancelAction: "Ok")
        case .limited:
            presentImagePicker()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { [weak self] status in
                DispatchQueue.main.async {
                    if status == .authorized {
                        self?.presentImagePicker()
                    } else {
                        AlertManager.shared.showAlert(title: "Permission Denied".localized(), message: "Please allow access to the photo library in Phone Settings to choose an avatar.".localized(), cancelAction: "Ok")
                    }
                }
            }
        @unknown default:
            AlertManager.shared.showAlert(title: "Permission Denied".localized(), message: "Please allow access to the photo library in Phone Settings to choose an avatar.".localized(), cancelAction: "Ok")
            
        }
    }
        
        private func presentImagePicker() {
            let picker = UIImagePickerController()
            picker.navigationBar.tintColor = UIColor.systemGreen
            picker.allowsEditing = true
            picker.delegate = self
            picker.sourceType = .photoLibrary
            picker.view.tintColor = .contrastGreen
            
            navigationItem.backButtonTitle = "Cancel".localized()
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
                    let task = URLSession.shared.dataTask(with: url) { data, response, error in
                        guard let data = data, error == nil else {
                            print("Error downloading image: \(error?.localizedDescription ?? "unknown error".localized())")
                            return
                        }
                        if let image = UIImage(data: data) {
                            DispatchQueue.main.async {
                                self.headerView.userPhotoImage.image = image
                            }
                            print ("set user image for the avatar")
                        } else {
                            print("Error creating image from data")
                        }
                    }
                    task.resume()
                }
            }
        }
    }
}

extension ProfileTableViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let cell = textField.superview?.superview?.superview as? ProfileTableViewCell,
              let indexPath = tableView.indexPath(for: cell),
              let text = textField.text else {
            return
        }
        
        if !text.isEmpty {
            switch indexPath.section {
            case 0:
                weights[indexPath.row] = text
                textField.text = ""
                tableView.reloadRows(at: [indexPath], with: .none)
                uploadWeightliftingRecords()
            case 1:
                reps[indexPath.row] = text
                textField.text = ""
                tableView.reloadRows(at: [indexPath], with: .none)
                uploadGymnasticRecords()
            default:
                break
            }
        }
    }
}

//extension ProfileTableViewController: UITextFieldDelegate {
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        guard let cell = textField.superview?.superview?.superview as? ProfileTableViewCell,
//              let indexPath = tableView.indexPath(for: cell),
//              let text = textField.text else {
//            return
//        }
//
//        if !text.isEmpty {
//            weights[indexPath.row] = text
//            tableView.reloadRows(at: [indexPath], with: .none)
//            self.uploadUserRecords()
//        }
//
//        textField.text = nil
//    }
//}
