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
    private let notificationCellIdentifier = "NotificationCell"

//    private var isEnglishSelected = true
//    private var isBodyweightNotificationOn = true
//    private var isECDNotificationOn = true
//    private var isStryuachNotificationOn = true
    
    // MARK: - Lifecycle
    
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
        
        // Register custom cells
        tableView.register(AboutTableViewCell.self, forCellReuseIdentifier: aboutCellIdentifier)
        tableView.register(EmailTableViewCell.self, forCellReuseIdentifier: emailCellIdentifier)
        tableView.register(RateTableViewCell.self, forCellReuseIdentifier: rateCellIdentifier)
        tableView.register(LanguageSwitchTableViewCell.self, forCellReuseIdentifier: languageSwitchCellIdentifier)
        tableView.register(NotificationTableViewCell.self, forCellReuseIdentifier: notificationCellIdentifier)
        
        // Set table view properties
        tableView.backgroundColor = .customDarkGray
        tableView.separatorStyle = .singleLine
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
    }
    
    // MARK: - UITableViewDataSource and Delegate
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
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
               return "App information"
           case 1:
               return "Language settings"
           case 2:
               return "Notifications settings"
           default:
               return nil
           }
       }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 3
        case 1:
            return 1
        case 2:
            return 3
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
            let cell = tableView.dequeueReusableCell(withIdentifier: languageSwitchCellIdentifier, for: indexPath) as! LanguageSwitchTableViewCell
            cell.configure(language: .english)
            return cell
        default:
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
                aboutThisAppVC.title = "About this App"
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
}

extension SettingsTableViewController: LanguageSwitchDelegate {
    func didSwitchLanguage(to language: Language) {
        // Handle language change here
        // You can save the user's language preference to UserDefaults or elsewhere
        // and update the app's language accordingly
    }
}
