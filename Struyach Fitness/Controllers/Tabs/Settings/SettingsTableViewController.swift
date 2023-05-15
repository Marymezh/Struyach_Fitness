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
    private var messages: [String] = []
    private var messageColors: [UIColor] = []
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
//        updateSubscriptionStatus()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateSubscriptionStatus()
//        print ("Messages on view will appear: \(messages)")
//   //     tableView.reloadData()
    }
    
    deinit {
           print ("settings vc is deallocated")
       }
    
    
    // MARK: - UITableViewDataSource and Delegate
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
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
           }
       }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 3
        case 1:
            return 3
        case 2:
            return 4
        case 3:
            return 1
        case 4:
            return 1
        default:
            return 0
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
            if indexPath.row == 0 {
                cell.configure(with: "Bodyweight")
                return cell
            } else if indexPath.row == 1 {
                cell.configure(with: "ECD")
                return cell
            } else if indexPath.row == 2 {
                cell.configure(with: "STRUYACH")
                return cell
            }
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
            
//            cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
//            cell.textLabel?.adjustsFontSizeToFitWidth = true
           
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: languageSwitchCellIdentifier, for: indexPath) as! LanguageSwitchTableViewCell
            cell.delegate = self
            cell.configure(language: LanguageManager.shared.currentLanguage)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: signOutCellIdentifier, for: indexPath) as! SignOutTableViewCell
            return cell
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
    
    private func sendEmailToDeveloper() {
        // Implement email functionality here
    }
    
    private func rateApp() {
        // Implement rating functionality here
        if let appURL = URL(string: "itms-apps://itunes.apple.com/app/id1234567890?action=write-review") {
            UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
        } else {
            // Unable to open app rating page - handle error
        }
    }
    
    private func updateSubscriptionStatus() {
       
        var updatedMessages = [String]()
        var updatedColors = [UIColor]()
        
        let dispatchGroup = DispatchGroup() // create a dispatch group
        
        for program in self.programsArray {
            dispatchGroup.enter() // notify the group that a task has started
            
            IAPManager.shared.getSubscriptionStatus(program: program) { color, message in
                updatedMessages.append(message)
                updatedColors.append(color)
                dispatchGroup.leave() // notify the group that a task has finished
            }
        }
        
        dispatchGroup.notify(queue: DispatchQueue.main) { [weak self] in
            guard let self = self else { return }// wait for all tasks to finish
            self.messages = updatedMessages
            self.messageColors = updatedColors
            self.tableView.reloadData()
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


