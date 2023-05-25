//
//  SettingsTableViewController.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 26/4/23.
//

import UIKit


final class SettingsTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    private let aboutCellIdentifier = "AboutCell"
    private let emailCellIdentifier = "EmailCell"
    private let rateCellIdentifier = "RateCell"
    private let languageSwitchCellIdentifier = "LanguageSwitchCell"
    private let signOutCellIdentifier = "SignOutCell"
    private let notificationCellIdentifier = "NotificationCell"
    private let subscriptionsCellIdentifier = "SubscriptionsCell"
    private var messages = [String]()
    private var messageColors = [UIColor]()
    private var subscriptionStatus = [false, false, false, false]
    private let programsArray = [K.ecd, K.struyach, K.pelvicPower, K.bellyBurner]
    
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
        
        // Register custom cells
        tableView.register(AboutTableViewCell.self, forCellReuseIdentifier: aboutCellIdentifier)
        tableView.register(EmailTableViewCell.self, forCellReuseIdentifier: emailCellIdentifier)
        tableView.register(RateTableViewCell.self, forCellReuseIdentifier: rateCellIdentifier)
        tableView.register(LanguageSwitchTableViewCell.self, forCellReuseIdentifier: languageSwitchCellIdentifier)
        tableView.register(NotificationTableViewCell.self, forCellReuseIdentifier: notificationCellIdentifier)
        tableView.register(SignOutTableViewCell.self, forCellReuseIdentifier: signOutCellIdentifier)
        tableView.register(SubscriptionTableViewCell.self, forCellReuseIdentifier: subscriptionsCellIdentifier)
        
        // Set table view properties
        tableView.backgroundColor = .customDarkGray
        tableView.separatorStyle = .singleLine

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        #if Client
        updateSubscriptionStatus()
        #endif
    }
    
    deinit {
           print ("settings vc is deallocated")
       }
    
    
    // MARK: - UITableViewDataSource and Delegate
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        #if Admin
        return 4
        #else
        return 5
        #endif
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 30))
        headerView.backgroundColor = .customDarkGray
        
        let titleLabel = UILabel(frame: CGRect(x: 15, y: 0, width: headerView.frame.width - 15, height: headerView.frame.height))
        titleLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        titleLabel.textColor = UIColor.systemGreen // set the desired title color here
        headerView.addSubview(titleLabel)
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
           switch section {
               #if Client
           case 0:
               return "App information".localized()
           case 1:
               return "Notifications settings".localized()
           case 2:
               return "Subscription status".localized()
           case 3:
               return "Language settings".localized()
           case 4:
               return "Log out or delete account".localized()
           default:
               return nil
               #else
           case 0:
               return "App information".localized()
           case 1:
               return "Notifications settings".localized()
           case 2:
               return "Language settings".localized()
           case 3:
               return "Log out or delete account".localized()
           default:
               return nil
               #endif
           }
       }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            #if Client
        case 0:
            return 3
        case 1:
            return 3
        case 2:
            return programsArray.count
        case 3:
            return 1
        case 4:
            return 1
        default:
            return 0
            #else
        case 0:
            return 3
        case 1:
            return 3
        case 2:
            return 1
        case 3:
            return 1
        default:
            return 0
            #endif
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: aboutCellIdentifier, for: indexPath) as! AboutTableViewCell
                return cell
            } else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: emailCellIdentifier, for: indexPath) as! EmailTableViewCell
                return cell
            } else if indexPath.row == 2 {
                let cell = tableView.dequeueReusableCell(withIdentifier: rateCellIdentifier, for: indexPath) as! RateTableViewCell
                return cell
            }
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: notificationCellIdentifier, for: indexPath) as! NotificationTableViewCell
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
                   
                 //  let isNotificationOn = NotificationsManager.shared.checkNotificationPermissions() && isSubscribed
                   cell.configure(with: programName, isSubscribed: isSubscribed)
            print (cell.programName ?? "no program")
            cell.notificationSwitch.programName = cell.programName
                   cell.notificationSwitch.addTarget(self, action: #selector(notificationSwitchChanged(_:)), for: .valueChanged)
                   
                   return cell
           
            #if Client
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: subscriptionsCellIdentifier, for: indexPath) as! SubscriptionTableViewCell
            
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
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: languageSwitchCellIdentifier, for: indexPath) as! LanguageSwitchTableViewCell
            cell.delegate = self
            cell.configure(language: LanguageManager.shared.currentLanguage)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: signOutCellIdentifier, for: indexPath) as! SignOutTableViewCell
            return cell
            
            #else
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: languageSwitchCellIdentifier, for: indexPath) as! LanguageSwitchTableViewCell
            cell.delegate = self
            cell.configure(language: LanguageManager.shared.currentLanguage)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: signOutCellIdentifier, for: indexPath) as! SignOutTableViewCell
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
                aboutThisAppVC.title = "About this App".localized()
                navigationController?.pushViewController(aboutThisAppVC, animated: true)
            case 1:
                //    sendEmailToDeveloper()
                if let cell = tableView.cellForRow(at: indexPath) as? EmailTableViewCell {
                    cell.sendEmail()
                }
            case 2:
                // go to app rating page
                //           rateApp()
                if let cell = tableView.cellForRow(at: indexPath) as? RateTableViewCell {
                    cell.openAppRatingPage()
                }
            default:
                break
            }
        case 1:
            switch indexPath.row {
            case 0:
                // handle notification cell
                break
            case 1:
                // handle language cell
                break
            default:
                break
            }
        case 2:
            // handle purchase cell
            break
        default:
            break
        }
    }
    
    // MARK: - Private methods
    
    private func updateSubscriptionStatus() {
       
        var updatedMessages = [String]()
        var updatedColors = [UIColor]()
        var isSubscribed = [Bool]()
        
        let dispatchGroup = DispatchGroup() // create a dispatch group
        
        for program in self.programsArray {
            dispatchGroup.enter() // notify the group that a task has started
            
            IAPManager.shared.getSubscriptionStatus(program: program) {isActive, color, message in
                updatedMessages.append(message)
                updatedColors.append(color)
                isSubscribed.append(isActive)
                dispatchGroup.leave() // notify the group that a task has finished
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
        guard let program = sender.programName else {
              print("No program name found")
              return
          }
        
        if sender.isOn {
            NotificationsManager.shared.subscribe(to: program)
            print ("switch on, should subscribe")
        } else {
            NotificationsManager.shared.unsubscribe(from: program)
            print ("switch off, should unsubscribe")
        }
        
    }
    
//    @objc private func notificationSwitchChanged(_ sender: UISwitch) {
//        if sender.isOn {
//            sender.setOn(false, animated: true)
//
//        } else {
//            sender.setOn(true,animated: true)
//        }
//
//       }
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


