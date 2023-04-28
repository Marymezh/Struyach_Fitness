//
//  ProgramsViewController.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 8/2/23.
//


import UIKit

final class ProgramsViewController: UITableViewController {
    
    //MARK: - Properties
    
    private let programsArray = ProgramDescriptionStorage.programArray
    private let currentUserEmail = UserDefaults.standard.string(forKey: "email")
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavbar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    //MARK: - Setup methods
    
    private func setupTableView () {
        tableView.backgroundColor = .customDarkGray
        tableView.register(ProgramTableViewCell.self, forCellReuseIdentifier: String(describing: ProgramTableViewCell.self))
        tableView.isScrollEnabled = false
    }
    
    private func setupNavbar() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Programs", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.largeTitleTextAttributes = [.backgroundColor: UIColor.customDarkGray ?? UIColor.blue, .foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 30, weight: .bold)]
        navigationController?.navigationBar.barTintColor =  .customTabBar
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
    }

    //MARK: - Table View datasource and delegate methods
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ProgramTableViewCell = tableView.dequeueReusableCell(withIdentifier: String(describing: ProgramTableViewCell.self), for: indexPath) as! ProgramTableViewCell
        
        cell.program = programsArray[indexPath.section]
        cell.backgroundView?.alpha = 0.5
        #if Admin
        cell.backgroundColor = .customDarkGray
        #else
        if let safeEmail = currentUserEmail, let programName = cell.programNameLabel.text{
            DatabaseManager.shared.getUser(email: safeEmail) {currentUser in
                guard let currentUser = currentUser else {return}
                let isUserSubscribed = currentUser.subscribedPrograms.contains(programName)
                cell.backgroundColor = isUserSubscribed ? .customDarkGray : .customLightGray
            }
        }
        #endif
        
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return programsArray.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 5
    }
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .customDarkGray
        return view
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let program = programsArray[indexPath.section]
        let programName = program.programName
        
        #if Admin
        // Allow full access to WorkoutsVC for the Admin user
        let programVC = WorkoutsViewController()
        programVC.title = programName
        navigationController?.pushViewController(programVC, animated: true)
        
        #else
        // Check if the user is subscribed to the program
        guard let currentUserEmail = currentUserEmail else { return }
        DatabaseManager.shared.getUser(email: currentUserEmail) {[weak self] currentUser in
            guard let self = self, let currentUser = currentUser else { return }
            
            let isUserSubscribed = currentUser.subscribedPrograms.contains(programName)
            
            if isUserSubscribed {
                // Push WorkoutsVC if user is subscribed
                let programVC = WorkoutsViewController()
                programVC.title = programName
                self.navigationController?.pushViewController(programVC, animated: true)
            } else {
                // Present PaywallViewController if user is not subscribed
                let paywallVC = PaywallViewController(programName: programName)
         print(programName)
                paywallVC.modalPresentationStyle = .automatic
                self.navigationController?.present(paywallVC, animated: true, completion: nil)
            }
        }
        #endif
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
       // let screenHeight = UIScreen.main.bounds.height
        let tableViewHeight = Double(tableView.frame.size.height - (navigationController?.navigationBar.frame.size.height)! - (tabBarController?.tabBar.frame.size.height)!)
        let rowHeight = tableViewHeight / (Double(programsArray.count) + 0.5)
        return rowHeight
    }
}

