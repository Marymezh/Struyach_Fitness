//
//  SettingsTableViewController.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 26/4/23.
//

import UIKit

final class SettingsTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    private var messages = [String]()
    private var messageColors = [UIColor]()
    private var subscriptionStatus = [false, false, false, false]
    private let programsArray = [K.ecd, K.struyach, K.pelvicPower, K.bellyBurner]
    
    let email: String
    let currentUserEmail = UserDefaults.standard.string(forKey: "email")

    // MARK: - Lifecycle
    
    init(email: String, style: UITableView.Style) {
        self.email = email
        super.init(style: style)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(AboutTableViewCell.self, forCellReuseIdentifier: AboutTableViewCell.reuseIdentifier)
        tableView.register(EmailTableViewCell.self, forCellReuseIdentifier: EmailTableViewCell.reuseIdentifier)
        tableView.register(RateTableViewCell.self, forCellReuseIdentifier: RateTableViewCell.reuseIdentifier)
        tableView.register(LanguageSwitchTableViewCell.self, forCellReuseIdentifier: LanguageSwitchTableViewCell.reuseIdentifier)
        tableView.register(NotificationTableViewCell.self, forCellReuseIdentifier: NotificationTableViewCell.reuseIdentifier)
        tableView.register(ManagementTableViewCell.self, forCellReuseIdentifier: ManagementTableViewCell.reuseIdentifier)
        tableView.register(SubscriptionTableViewCell.self, forCellReuseIdentifier: SubscriptionTableViewCell.reuseIdentifier)
        tableView.register(HideEmailTableViewCell.self, forCellReuseIdentifier: HideEmailTableViewCell.reuseIdentifier)
        
        tableView.backgroundColor = .customDarkGray
        tableView.separatorStyle = .singleLine
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
    
    // MARK: - UITableViewDataSource and Delegate
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        #if Admin
        return 5
        #else
        return 7
        #endif
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 45))
        headerView.backgroundColor = .customDarkGray
        
        let titleLabel = UILabel(frame: CGRect(x: 15, y: 0, width: headerView.frame.width - 15, height: headerView.frame.height))
        titleLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        titleLabel.textColor = UIColor.systemGreen // set the desired title color here
        headerView.addSubview(titleLabel)
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
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
               return "Language settings".localized()
           case 6:
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
               return "Language settings".localized()
           case 4:
               return "Log out or delete account".localized()
           default:
               return nil
               #endif
           }
       }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            #if Client
        case 0:
            return 3
        case 1:
            return 2
        case 2:
            return 3
        case 3:
            return programsArray.count
        case 4:
            return 2
        case 5:
            return 1
        case 6:
            return 2
        default:
            return 0
            #else
        case 0:
            return 3
        case 1:
            return 2
        case 2:
            return 3
        case 3:
            return 1
        case 4:
            return 2
        default:
            return 0
            #endif
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            // App info section
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: AboutTableViewCell.reuseIdentifier, for: indexPath) as! AboutTableViewCell
                cell.containerView.layer.cornerRadius = 15
                cell.containerView.layer.masksToBounds = true
                cell.containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                return cell
            } else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: EmailTableViewCell.reuseIdentifier, for: indexPath) as! EmailTableViewCell
                cell.containerView.layer.cornerRadius = 0
                return cell
            } else if indexPath.row == 2 {
                let cell = tableView.dequeueReusableCell(withIdentifier: RateTableViewCell.reuseIdentifier, for: indexPath) as! RateTableViewCell
                cell.containerView.layer.cornerRadius = 15
                cell.containerView.layer.masksToBounds = true
                cell.containerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                return cell
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
                print ("hide email switch is on = \(hideEmail)")

                
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
                cell.titleLabel.text = "Fetching subscription status..."
                cell.colorLabel.backgroundColor = .yellow
                cell.termsLabel.text = ""
            } else {
                cell.titleLabel.text = programsArray[indexPath.row]
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
        case 5:
            //language settings
            let cell = tableView.dequeueReusableCell(withIdentifier: LanguageSwitchTableViewCell.reuseIdentifier, for: indexPath) as! LanguageSwitchTableViewCell
            cell.delegate = self
            cell.configure(language: LanguageManager.shared.currentLanguage)
            return cell
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
            
#else
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: LanguageSwitchTableViewCell.reuseIdentifier, for: indexPath) as! LanguageSwitchTableViewCell
            cell.delegate = self
            cell.configure(language: LanguageManager.shared.currentLanguage)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: ManagementTableViewCell.reuseIdentifier, for: indexPath) as! ManagementTableViewCell
            if indexPath.row == 0 {
                cell.containerView.layer.cornerRadius = 15
                cell.containerView.layer.masksToBounds = true
                cell.containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                cell.titleLabel.text = "Sign out".localized()
                cell.imgView.image = UIImage(systemName: "trash")
            } else {
                cell.containerView.layer.cornerRadius = 15
                cell.containerView.layer.masksToBounds = true
                cell.containerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                cell.titleLabel.text = "Delete account and all data".localized()
                cell.imgView.image = UIImage(systemName: "xmark.square")
            }
            return cell
#endif
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let aboutThisAppVC = AboutViewController()
                aboutThisAppVC.title = "About this app".localized()
                navigationController?.pushViewController(aboutThisAppVC, animated: true)
            case 1:
                //    sendEmailToDeveloper
                if let cell = tableView.cellForRow(at: indexPath) as? EmailTableViewCell {
                    cell.sendEmail { error in
                        if let error = error {
                            AlertManager.shared.showAlert(title: "Error".localized(), message: error.localizedDescription, cancelAction: "Ok", style: .cancel)
                        }
                    }
                }
            case 2:
                // go to app rating page
                if let cell = tableView.cellForRow(at: indexPath) as? RateTableViewCell {
                    cell.openAppRatingPage { success in
                        if !success {
                            AlertManager.shared.showAlert(title: "Error".localized(), message: "Unable to open app rating page".localized(), cancelAction: "Ok", style: .cancel)
                        }
                    }
                }
            default:
                break
            }
        case 1:
            switch indexPath.row {
            case 0: changeUserName()
            default: break
            }
            #if Admin
        case 4:
            switch indexPath.row {
            case 0: signOut()
            default:  print("delete account")
                //delete account
            }

            #else

        case 4:
            switch indexPath.row {
            case 0: restorePurchases()
            default: requestRefund()
            }
        case 6:
            switch indexPath.row {
            case 0: signOut()
            default:  print("delete account")
                //delete account
            }

            #endif
       
        default:
            break
        }
    }
    
    // MARK: - Private methods
    
    private func restorePurchases() {
        IAPManager.shared.restorePurchases { result in
            switch result {
            case .failure(let error):
                let message = String(format: "Unable to restore purchases: %@".localized(), error.localizedDescription)
                AlertManager.shared.showAlert(title: "Failed".localized(), message: message, cancelAction: "Ok", style: .cancel)
            case .success(_):
                AlertManager.shared.showAlert(title: "Success".localized(), message: "Your purchases are successfully restored!".localized(), cancelAction: "Ok", style: .cancel)
            }
        }
    }
    
    private func requestRefund() {
        if let refundURL = URL(string: "https://support.apple.com/en-us/HT204084") {
            UIApplication.shared.open(refundURL, options: [:], completionHandler: nil)
        }
    }
    
    private func signOut() {
            let alert = UIAlertController(title: "Sign Out".localized(), message: "Are you sure you would like to sign out?".localized(), preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
            alert.addAction(UIAlertAction(title: "Sign Out".localized(), style: .destructive, handler: { action in
                AuthManager.shared.signOut { success in
                    if success {
                        IAPManager.shared.logOutRevenueCat { error in
                            AlertManager.shared.showAlert(title: "Error".localized(), message: "Unable to log out from purchases", cancelAction: "Cancel".localized(), style: .cancel)
                            print (error.localizedDescription)
                        }
                        DispatchQueue.main.async {
                            UserDefaults.standard.set(nil, forKey: "userName")
                            UserDefaults.standard.set(nil, forKey: "email")
                            UserDefaults.standard.set(nil, forKey: "userImage")
                            
                    //update root vc
                            let signInVC = LoginViewController()
                            let navVC = UINavigationController(rootViewController: signInVC)
                            navVC.navigationBar.prefersLargeTitles = false
                            let window = UIApplication.shared.windows.first
                            UIView.transition(with: window!, duration: 1, options: [.transitionCrossDissolve, .allowAnimatedContent], animations: {
                                window?.rootViewController = navVC
                            }, completion: nil)
                        }
                    }
                }
            }))
            present(alert, animated: true)
    }
    
    private func changeUserName() {
        let alertController = UIAlertController(title: "Change user name".localized(), message: nil, preferredStyle: .alert)
        alertController.addTextField { textfield in
            textfield.placeholder = "Enter new name here".localized()
        }
        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .default)
        let changeAction = UIAlertAction(title: "Save".localized(), style: .default) { action in
            if let text = alertController.textFields?[0].text,
               text != "" {
                DatabaseManager.shared.updateUserName(email: self.email, newUserName: text) { success in
                    if success {
                        UserDefaults.standard.set(text, forKey: "userName")
                    }
                }
            } else {
                AlertManager.shared.showAlert(title: "Error".localized(), message: "User name can not be blank!".localized(), cancelAction: "Cancel".localized(), style: .cancel)
            }
        }
        
        alertController.addAction(changeAction)
        alertController.addAction(cancelAction)

        alertController.view.tintColor = .darkGray
        present(alertController, animated: true)
    }
    
    @objc private func hideEmailSwitchChanged(_ sender: UISwitch) {
        DatabaseManager.shared.hideOrShowEmail(email: self.email, isHidden: sender.isOn) { success in
            UserDefaults.standard.set(sender.isOn, forKey: "hideEmail")
            
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

extension SettingsTableViewController: LanguageSwitchDelegate {
    func didSwitchLanguage(to language: Language) {
        LanguageManager.shared.setCurrentLanguage(language)
        tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.updateRootViewController()
        }
    }

    func updateRootViewController() {
        let tabBarController = TabBarController()
        let window = UIApplication.shared.windows.first
        UIView.transition(with: window!, duration: 1, options: [.transitionCrossDissolve, .allowAnimatedContent], animations: {
            window?.rootViewController = tabBarController
        }, completion: nil)
    }
}


