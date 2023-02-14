//
//  ProfileTableViewController.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 8/2/23.
//

import UIKit

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
        updateWeights()
        setupNavigationBar()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
    }
    
    private func setupTableView() {
        tableView.backgroundColor = .systemTeal
        tableView.register(ProfileTableViewCell.self, forCellReuseIdentifier: String(describing: ProfileTableViewCell.self))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CellID")
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        headerView.isUserInteractionEnabled = true
    }
    
   private func setupNavigationBar () {
        navigationController?.navigationBar.tintColor = .darkGray
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
                        //to fix when login after logout - userName becomes blank 
                        UserDefaults.standard.set(nil, forKey: "userName")
                        UserDefaults.standard.set(nil, forKey: "email")
                        UserDefaults.standard.set(nil, forKey: "savedWeights")
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
    
    private func updateWeights() {
        if let savedWeights = UserDefaults.standard.object(forKey: "savedWeights")  as? [String] {
            if savedWeights != [""] {
                weights = savedWeights
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
            cell.backgroundColor = UIColor(named: "tealLight")
            cell.textLabel?.text = "PERSONAL RECORDS"
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.font = UIFont.systemFont(ofSize: 22, weight: .bold)
            return cell
        default:
            let cell: ProfileTableViewCell = tableView.dequeueReusableCell(withIdentifier: String(describing: ProfileTableViewCell.self), for: indexPath) as! ProfileTableViewCell
            
            cell.backgroundColor = UIColor(named: "tealLight")
            cell.movementLabel.text = movements[indexPath.row]
            cell.weightIsSet = { text in
                self.weights.remove(at: indexPath.row)
                self.weights.insert(text, at: indexPath.row)
                tableView.reloadData()
                UserDefaults.standard.set(self.weights, forKey: "savedWeights")
            }
            cell.weightLabel.text = "\(weights[indexPath.row]) kg"

            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        
//        headerView.onNameChanged = {
//            tableView.performBatchUpdates(nil, completion: nil)
//        }
        return headerView
    }
}
