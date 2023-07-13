//
//  SettingsTableViewController.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 26/4/23.
//

import UIKit

final class SettingsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    // MARK: - Properties
    
    private var messages = [String]()
    private var messageColors = [UIColor]()
    private var subscriptionStatus = [false, false, false, false]
    private let programsArray = [K.ecd, K.struyach, K.pelvicPower, K.bellyBurner]
    
    private let activityView = ActivityView()
    private var tableView = UITableView(frame: .zero, style: .grouped)
    
    let email: String
    let currentUserEmail = UserDefaults.standard.string(forKey: "email")

    // MARK: - Lifecycle
    
    init(email: String) {
        self.email = email
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        #if Client
        updateSubscriptionStatus()
        #endif
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UserDefaults.standard.synchronize()
    }
    
    deinit {
           print ("settings vc is deallocated")
       }
    
    private func setupSubviews() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(InfoTableViewCell.self, forCellReuseIdentifier: InfoTableViewCell.reuseIdentifier)
        tableView.register(EmailTableViewCell.self, forCellReuseIdentifier: EmailTableViewCell.reuseIdentifier)
        tableView.register(RateTableViewCell.self, forCellReuseIdentifier: RateTableViewCell.reuseIdentifier)
        tableView.register(NotificationTableViewCell.self, forCellReuseIdentifier: NotificationTableViewCell.reuseIdentifier)
        tableView.register(ManagementTableViewCell.self, forCellReuseIdentifier: ManagementTableViewCell.reuseIdentifier)
        tableView.register(SubscriptionTableViewCell.self, forCellReuseIdentifier: SubscriptionTableViewCell.reuseIdentifier)
        tableView.register(HideEmailTableViewCell.self, forCellReuseIdentifier: HideEmailTableViewCell.reuseIdentifier)
        
        tableView.backgroundColor = .customDarkGray
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30)
        tableView.separatorColor = .black
        
        view.addSubviews(tableView, activityView)
        tableView.toAutoLayout()
        activityView.toAutoLayout()
        
       let constraints = [
        tableView.topAnchor.constraint(equalTo: view.topAnchor),
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        
        activityView.topAnchor.constraint(equalTo: view.topAnchor),
        activityView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        activityView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        activityView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
       ]
       
       NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: - UITableViewDataSource and Delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        #if Admin
        return 4
        #else
        return 6
        #endif
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 45))
        headerView.backgroundColor = .customDarkGray
        let titleLabel = UILabel(frame: CGRect(x: 15, y: 0, width: headerView.frame.width - 15, height: headerView.frame.height))
        titleLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        titleLabel.textColor = UIColor.systemGreen
        headerView.addSubview(titleLabel)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
           switch section {
               #if Client
           case 0:
               return "App information".localized()
           case 1:
               return "User profile settings".localized()
           case 2:
               return "Notifications settings".localized()
           case 3:
               return "Subscription status".localized()
           case 4:
               return "Manage subscriptions".localized()
           case 5:
               return "Log out or delete account".localized()
           default:
               return nil
               #else
           case 0:
               return "App information".localized()
           case 1:
               return "User profile settings".localized()
           case 2:
               return "Notifications settings".localized()
           case 3:
               return "Log out or delete account".localized()
           default:
               return nil
               #endif
           }
       }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            #if Client
        case 0:
            return 4
        case 1:
            return 2
        case 2:
            return 3
        case 3:
            return programsArray.count
        case 4:
            return 2
        case 5:
            return 2
        default:
            return 0
            #else
        case 0:
            return 4
        case 1:
            return 2
        case 2:
            return 3
        case 3:
            return 2
        default:
            return 0
            #endif
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            // App info section
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: InfoTableViewCell.reuseIdentifier, for: indexPath) as! InfoTableViewCell
                cell.titleLabel.text = "About this app".localized()
                cell.imgView.image = UIImage(systemName: "info.circle")
                cell.containerView.layer.cornerRadius = 15
                cell.containerView.layer.masksToBounds = true
                cell.containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: EmailTableViewCell.reuseIdentifier, for: indexPath) as! EmailTableViewCell
                cell.containerView.layer.cornerRadius = 0
                cell.onClose = { result in
                    switch result {
                    case .sent:
                        AlertManager.shared.showAlert(title: "Success".localized(), message: "Your message is successfully sent! \nThank you for your feedback!".localized(), cancelAction: "Ok")
                    case .saved:
                        AlertManager.shared.showAlert(title: "Done".localized(), message: "Your message is saved to drafts".localized(), cancelAction: "Ok")
                    case .cancelled:
                        AlertManager.shared.showAlert(title: "Done".localized(), message: "Cancelled sending message to the developer".localized(), cancelAction: "Ok")
                    case .failed:
                        AlertManager.shared.showAlert(title: "Warning".localized(), message: "Error sending message".localized(), cancelAction: "Cancel".localized())
                    @unknown default:
                        print ("unknown error")
                    }
                }
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: RateTableViewCell.reuseIdentifier, for: indexPath) as! RateTableViewCell
                cell.containerView.layer.cornerRadius = 0
                return cell
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: InfoTableViewCell.reuseIdentifier, for: indexPath) as! InfoTableViewCell
                cell.titleLabel.text = "Privacy Policy".localized()
                cell.imgView.image = UIImage(systemName: "lock.circle")
                cell.imgView.tintColor = .systemGreen
                cell.containerView.layer.cornerRadius = 15
                cell.containerView.layer.masksToBounds = true
                cell.containerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                return cell
            default: break
            }
        case 1:
            // user profile settings
            switch indexPath.row {
            case 0: let cell = tableView.dequeueReusableCell(withIdentifier: ManagementTableViewCell.reuseIdentifier, for: indexPath) as! ManagementTableViewCell
                cell.titleLabel.text = "Change user name".localized()
                cell.titleLabel.textColor = .white
                cell.imgView.image = UIImage(systemName: "person")
                cell.imgView.tintColor = .systemGreen
                cell.containerView.layer.cornerRadius = 15
                cell.containerView.layer.masksToBounds = true
                cell.containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                return cell
            default: let cell = tableView.dequeueReusableCell(withIdentifier: HideEmailTableViewCell.reuseIdentifier, for: indexPath) as! HideEmailTableViewCell
                cell.containerView.layer.cornerRadius = 15
                cell.containerView.layer.masksToBounds = true
                cell.containerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                cell.hideEmailSwitch.addTarget(self, action: #selector(hideEmailSwitchChanged(_:)), for: .valueChanged)
                let hideEmail = UserDefaults.standard.bool(forKey: "hideEmail")
                cell.hideEmailSwitch.isOn = hideEmail
                return cell
            }
            
        case 2:
            // Notification settings
            let cell = tableView.dequeueReusableCell(withIdentifier: NotificationTableViewCell.reuseIdentifier, for: indexPath) as! NotificationTableViewCell
            
            if indexPath.row == 0 {
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
               
            let programName: String
            let isSubscribed: Bool
                   switch indexPath.row {
                   case 0:
                       programName = K.bodyweight
                       isSubscribed = true // Assume all users are subscribed to Bodyweight plan
                   case 1:
                       programName = K.ecd
                       isSubscribed = subscriptionStatus[0]
                   case 2:
                       programName = K.struyach
                       isSubscribed = subscriptionStatus[1]
                   default:
                       programName = ""
                       isSubscribed = false
                   }
                   
            cell.configure(with: programName, isSubscribed: isSubscribed)
            cell.notificationSwitch.programName = cell.programName
            cell.notificationSwitch.addTarget(self, action: #selector(notificationSwitchChanged(_:)), for: .valueChanged)
            return cell
           
            #if Client
        case 3:
            // subscription status
            let cell = tableView.dequeueReusableCell(withIdentifier: SubscriptionTableViewCell.reuseIdentifier, for: indexPath) as! SubscriptionTableViewCell
            
            if indexPath.row == 0 {
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
            
            if messages.isEmpty {
                cell.titleLabel.text = "Fetching subscription status...".localized()
                cell.colorLabel.backgroundColor = .yellow
                cell.termsLabel.text = ""
            } else {
                cell.titleLabel.text = programsArray[indexPath.row].localized()
                cell.colorLabel.backgroundColor = messageColors[indexPath.row]
                cell.termsLabel.text = messages[indexPath.row]
            }
            
            return cell
        case 4: let cell =
            // manage subscriptions
            tableView.dequeueReusableCell(withIdentifier: ManagementTableViewCell.reuseIdentifier, for: indexPath) as! ManagementTableViewCell
            if indexPath.row == 0 {
                cell.containerView.layer.cornerRadius = 15
                cell.containerView.layer.masksToBounds = true
                cell.containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                cell.titleLabel.text = "Restore purchases".localized()
                cell.titleLabel.textColor = .white
                cell.imgView.image = UIImage(systemName: "arrow.clockwise")
                cell.imgView.tintColor = .systemGreen
            } else {
                cell.containerView.layer.cornerRadius = 15
                cell.containerView.layer.masksToBounds = true
                cell.containerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                cell.titleLabel.text = "Request a refund".localized()
                cell.titleLabel.textColor = .white
                cell.imgView.image = UIImage(systemName: "dollarsign.circle")
                cell.imgView.tintColor = .systemGreen
            }
            return cell
            #endif
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: ManagementTableViewCell.reuseIdentifier, for: indexPath) as! ManagementTableViewCell
            if indexPath.row == 0 {
                cell.containerView.layer.cornerRadius = 15
                cell.containerView.layer.masksToBounds = true
                cell.containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                cell.titleLabel.text = "Sign out".localized()
                cell.titleLabel.textColor = .systemRed
                cell.imgView.image = UIImage(systemName: "xmark.square")
                cell.imgView.tintColor = .systemRed

            } else {
                cell.containerView.layer.cornerRadius = 15
                cell.containerView.layer.masksToBounds = true
                cell.containerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                cell.titleLabel.text = "Delete account and all data".localized()
                cell.titleLabel.textColor = .systemRed
                cell.imgView.image = UIImage(systemName: "trash")
                cell.imgView.tintColor = .systemRed
            }
            return cell
        }
        return UITableViewCell()
    }
    
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let appDescription = K.appDescription.localized()
                let aboutThisAppVC = AboutViewController(text: appDescription)
                aboutThisAppVC.title = "About this app".localized()
                aboutThisAppVC.imageView.image = UIImage(named: "coach")
                navigationController?.pushViewController(aboutThisAppVC, animated: true)
            case 1:
                //    sendEmailToDeveloper
                if let cell = tableView.cellForRow(at: indexPath) as? EmailTableViewCell {
                    cell.showMailComposer { error in
                        if let _ = error {
                            AlertManager.shared.showAlert(title: "Error".localized(), message: "You can't send email, check if Mail app is installed and set to send emails. Or you can sand your email manually to feedback.struyach@gmail.com".localized(), cancelAction: "Ok")
                        }
                    }
                }
            case 2:
                // go to app rating page
                if let cell = tableView.cellForRow(at: indexPath) as? RateTableViewCell {
                    cell.openAppRatingPage { success in
                        if !success {
                            print ("Unable to open app rating page")
                            AlertManager.shared.showAlert(title: "Error".localized(), message: "Unable to open app rating page".localized(), cancelAction: "Ok")
                        }
                    }
                }
            case 3:
                // go to privacyPolicy
                let privacyPolicy = K.privacyPolicy.localized()
                let policyVC = AboutViewController(text: privacyPolicy)
                policyVC.title = "Privacy Policy".localized()
                
                policyVC.imageView.image = UIImage(named: "IMG_2930")
                navigationController?.pushViewController(policyVC, animated: true)
                
            default: break
            }
        case 1:
            switch indexPath.row {
            case 0: changeUserName()
            default: break
            }
            #if Admin
        case 3:
            switch indexPath.row {
            case 0: signOut()
            default: deleteAccount()
            }

            #else

        case 4:
            switch indexPath.row {
            case 0: restorePurchases()
            default: requestRefund()
            }
        case 5:
            switch indexPath.row {
            case 0: signOut()
            default: deleteAccount()
            }

            #endif
       
        default:
            break
        }
    }
    
    // MARK: - Private methods
    
    private func restorePurchases() {
        activityView.showActivityIndicator()
        IAPManager.shared.restorePurchases { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .failure(let error):
                self.activityView.hide()
                let message = String(format: "Unable to restore purchases: %@".localized(), error.localizedDescription)
                AlertManager.shared.showAlert(title: "Failed".localized(), message: message, cancelAction: "Ok")
            case .success(true):
                    self.activityView.hide()
                    AlertManager.shared.showAlert(title: "Success".localized(), message: "Your purchases are successfully restored!".localized(), cancelAction: "Ok")
            case .success(false): 
                    self.activityView.hide()
                    AlertManager.shared.showAlert(title: "No purchases detected".localized(), message: "You haven't purchased anything yet".localized(), cancelAction: "Ok")
               
            }
        }
    }
    
    private func requestRefund() {
        if let refundURL = URL(string: "https://support.apple.com/en-us/HT204084") {
            UIApplication.shared.open(refundURL, options: [:], completionHandler: nil)
        }
    }
    
    private func clearUserDefaults() {
        UserDefaults.standard.set(nil, forKey: "userName")
        UserDefaults.standard.set(nil, forKey: "email")
        UserDefaults.standard.set(nil, forKey: "userImage")
        UserDefaults.standard.set(nil, forKey: "likedPosts")
        UserDefaults.standard.set(nil, forKey: "likedWorkouts")
        UserDefaults.standard.set(nil, forKey: "userUID")
        UserDefaults.standard.set(nil, forKey: "hideEmail")
        UserDefaults.standard.set(nil, forKey: "fcmToken")
        UserDefaults.standard.set(false, forKey: "program")
    }
    
    private func signOut() {
        activityView.showActivityIndicator()
        AlertManager.shared.showActionSheet(title: "Sign Out".localized(), message: "Are you sure you would like to sign out?".localized(), cancelHandler: { [weak self] _ in
            guard let self = self else {return}
            print("cancelled signing out")
            self.activityView.hide()
        }, confirmActionTitle: "Sign Out".localized()) { action in
            AuthManager.shared.signOut { [weak self] success in
                guard let self = self else {return}
                if success {
                    self.activityView.hide()
                    DispatchQueue.main.async {
                        self.clearUserDefaults()
                        let signInVC = LoginViewController()
                        let window = UIApplication.shared.windows.first
                        UIView.transition(with: window!, duration: 1, options: [.transitionCrossDissolve, .allowAnimatedContent], animations: {
                        let navVC = UINavigationController(rootViewController: signInVC)
                        window?.rootViewController = navVC
                    }, completion: nil)
                    }
                } else {
                    self.activityView.hide()
                    AlertManager.shared.showAlert(title: "Error".lowercased(), message: "Unable to sign out".localized(), cancelAction: "Cancel".localized())
                }
            }
        }
    }
    
    private func deleteAccount() {
        activityView.showActivityIndicator()
        AlertManager.shared.showActionSheet(title: "Delete Account".localized(), message: K.accountDeleteMessage.localized(), cancelHandler: { [weak self] _ in
            guard let self = self else {return}
            print("cancelled account deletion")
            self.activityView.hide()
        }, confirmActionTitle: "Delete Account".localized()) { action in
            AlertManager.shared.showAlert(title: "Confirm".localized(), message: "If you for sure want to permanently delete your account, please type \"Confirm\" below".localized(), placeholderText: "Confirm", cancelAction: "Cancel".localized(), cancelCompletion: { [weak self] _ in
                guard let self = self else {return}
                print("cancelled account deletion")
                self.activityView.hide()
            }, confirmActionTitle: "Confirm".localized()) { [weak self] success, text in
                guard let self = self else {return}
                if let text = text?.trimmingCharacters(in: .whitespacesAndNewlines), text == "Confirm" {
                    StorageManager.shared.deleteUserData(email: self.email) { [weak self] storageSuccess, storageError in
                        guard let self = self else {return}
                        guard storageSuccess else {
                            if let error = storageError {
                                self.activityView.hide()
                                let message = String(format: "User data cannot be deleted from storage: %@".localized(), error.localizedDescription)
                                AlertManager.shared.showAlert(title: "Error".localized(), message: message, cancelAction: "Cancel".localized())
                            }
                            return
                        }
                        DatabaseManager.shared.deleteAllBlogCommentsForUser(userId: self.email) { [weak self] blogCommentsSuccess in
                            guard let self = self else {return}
                            guard blogCommentsSuccess else {
                                self.activityView.hide()
                                AlertManager.shared.showAlert(title: "Error".localized(), message: "Blog comments cannot be deleted".localized(), cancelAction: "Cancel".localized())
                                return
                            }
                            DatabaseManager.shared.deleteAllWorkoutCommentsForUser(userId: self.email) { [weak self] workoutCommentsSuccess in
                                guard let self = self else {return}
                                guard workoutCommentsSuccess else {
                                    self.activityView.hide()
                                    AlertManager.shared.showAlert(title: "Error".localized(), message: "Workout comments cannot be deleted".localized(), cancelAction: "Cancel".localized())
                                    return
                                }
                                DatabaseManager.shared.deleteUser(email: self.email) {[weak self] deleteUserSuccess in
                                    guard let self = self else {return}
                                    guard deleteUserSuccess else {
                                        self.activityView.hide()
                                        AlertManager.shared.showAlert(title: "Error".localized(), message: "User and its data cannot be deleted from the database".localized(), cancelAction: "Cancel".localized())
                                        return
                                    }
                                    AuthManager.shared.deleteAccount { [weak self] result in
                                        guard let self = self else {return}
                                        switch result {
                                        case .failure(_):
                                            self.activityView.hide()
                                            #if Admin
                                            AlertManager.shared.showAlert(title: "Warning".localized(), message: "Your account data, including photos, videos, and comments, has been successfully deleted. However, in order to complete the account deletion process, please contact the developer to delete your account from our authentication system.".localized(), cancelAction: "Ok")
                                            #else
                                            AlertManager.shared.showAlert(title: "Warning".localized(), message: "This operation is sensitive and requires recent authentication. Log in again before retrying this request".localized(), cancelAction: "Ok")
                                            #endif
                                        case .success:
                                            self.activityView.hide()
                                            print ("user is deleted successfully")
                                            DispatchQueue.main.async {
                                                self.clearUserDefaults()
                                                UserDefaults.standard.set(false, forKey: "HasAgreedToPrivacyPolicy")
                                                let signInVC = LoginViewController()
                                                let window = UIApplication.shared.windows.first
                                                UIView.transition(with: window!, duration: 1, options: [.transitionCrossDissolve, .allowAnimatedContent], animations: {
                                                    let navVC = UINavigationController(rootViewController: signInVC)
                                                    window?.rootViewController = navVC
                                                }, completion: nil)
                                            }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                                AlertManager.shared.showAlert(title: "Done".localized(), message: "Your account, including photos, videos, and comments, has been successfully deleted. But we hope that you will come back to train with us again!".localized(), cancelAction: "Ok")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                } else {
                    self.activityView.hide()
                    AlertManager.shared.showAlert(title: "Warning".localized(), message: "Incorrect confirmation entry, check spelling".localized(), cancelAction: "Retry")
                }
            }
        }
    }
    
    private func changeUserName() {
        AlertManager.shared.showAlert(title: "Change user name".localized(), message: nil, placeholderText: "Enter new name here".localized(), cancelAction: "Cancel".localized(), confirmActionTitle: "Save".localized()) { [weak self] success, text in
            guard let self = self else {return}
            if success {
                if let text = text, text != "" {
                    DatabaseManager.shared.updateUserName(email: self.email, newUserName: text) { success in
                        if success {
                            UserDefaults.standard.set(text, forKey: "userName")
                            AlertManager.shared.showAlert(title: "Done".localized(), message: "User name is successfully changed".localized(), cancelAction: "Ok")
                        } else {
                            AlertManager.shared.showAlert(title: "Warning".localized(), message: "Unable to change user's name".localized(), cancelAction: "Ok")
                        }
                    }
                }
                } else {
                    AlertManager.shared.showAlert(title: "Error".localized(), message: "User name can not be blank!".localized(), cancelAction: "Cancel".localized())
            }
        }
    }
    
    @objc private func hideEmailSwitchChanged(_ sender: UISwitch) {
        DatabaseManager.shared.hideOrShowEmail(email: self.email, isHidden: sender.isOn) { success in
            if success {
                UserDefaults.standard.set(sender.isOn, forKey: "hideEmail")
            } else {
                AlertManager.shared.showAlert(title: "Warning".localized(), message: "Unable hide/show email".localized(), cancelAction: "Ok")
            }
        }
    }

    private func updateSubscriptionStatus() {
        var updatedMessages = [String]()
        var updatedColors = [UIColor]()
        var isSubscribed = [Bool]()
        let dispatchGroup = DispatchGroup()
        
        for program in self.programsArray {
            dispatchGroup.enter()
            
            IAPManager.shared.getSubscriptionStatus(program: program) {isActive, color, message in
                updatedMessages.append(message)
                updatedColors.append(color)
                isSubscribed.append(isActive)
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: DispatchQueue.main) { [weak self] in
            guard let self = self else { return }// wait for all tasks to finish
            self.messages = updatedMessages
            self.messageColors = updatedColors
            self.subscriptionStatus = isSubscribed
            self.tableView.reloadData()
        }
    }
    
    @objc private func notificationSwitchChanged(_ sender: UISwitch) {
        print("executing func \(#function)")
        guard let program = sender.programName?.replacingOccurrences(of: " ", with: "_") else { return }
        UserDefaults.standard.set(sender.isOn, forKey: program)
        
        if sender.isOn {
            NotificationsManager.shared.subscribe(to: program)
        } else {
            NotificationsManager.shared.unsubscribe(from: program)
        }
    }
}


