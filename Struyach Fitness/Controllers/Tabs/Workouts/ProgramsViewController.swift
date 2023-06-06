//
//  ProgramsViewController.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 8/2/23.
//


import UIKit
import RevenueCat

final class ProgramsViewController: UITableViewController {
    
    //MARK: - Properties
    
    private let programsArray = ProgramDescriptionStorage.programArray
 //   private let programsDescriptionArray = K.shortPlanDescriptions
    private let currentUserEmail = UserDefaults.standard.string(forKey: "email")

    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavbar()
  //      syncPurchases()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
        tableView.reloadData()
    }
    
    deinit {
           print ("programs vc is deallocated")
       }
    
    //MARK: - Setup methods
    
    private func setupTableView () {
        tableView.backgroundColor = .customDarkGray
        tableView.register(ProgramTableViewCell.self, forCellReuseIdentifier: String(describing: ProgramTableViewCell.self))
        tableView.isScrollEnabled = false
    }
    
    private func setupNavbar() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Training Plans".localized(), style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.largeTitleTextAttributes = [.backgroundColor: UIColor.customDarkGray ?? UIColor.blue, .foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 28, weight: .bold)]
        navigationController?.navigationBar.barTintColor =  .customTabBar
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
    }
    
    private func syncPurchases() {
        IAPManager.shared.syncPurchases { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .failure(let error):
                let message = String(format: "Unable to syncronize purchases: %@".localized(), error.localizedDescription)
                AlertManager.shared.showAlert(title: "Error".localized(), message:  message, cancelAction: "Ok", style: .cancel)
            case .success(_):
                self.tableView.reloadData()
            }
        }
    }

   
    //MARK: - Table View datasource and delegate methods
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ProgramTableViewCell = tableView.dequeueReusableCell(withIdentifier: String(describing: ProgramTableViewCell.self), for: indexPath) as! ProgramTableViewCell

        cell.program = programsArray[indexPath.section]
        cell.backgroundView?.alpha = 0.5
        
        #if Admin
        cell.backgroundColor = .customDarkGray
        #else
        if let programName = cell.programNameLabel.text {
            if programName == K.bodyweight {
                cell.backgroundColor = .customDarkGray
            } else {
                IAPManager.shared.checkCustomerStatus(program: programName) {[weak cell] success in
                    guard let cell = cell else {return}
                    if success {
                    print ("entitlement for \(programName) is active")
                    }
                    cell.backgroundColor = success ? .customDarkGray : .customLightGray
                }
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
        if programName == K.bodyweight {
            //Push WorkoutsVC for the free program
            let programVC = WorkoutsViewController()
            programVC.title = programName
            self.navigationController?.pushViewController(programVC, animated: true)
        } else {
            //cheching customer subscriptions on Revenue cat
            IAPManager.shared.checkCustomerStatus(program: programName) {[weak self] success in
                guard let self = self else {return}
                if success {
                    //Push WorkoutsVC if entitlement is active
                    let programVC = WorkoutsViewController()
                    programVC.title = programName
                    self.navigationController?.pushViewController(programVC, animated: true)
                } else {
                    // Present PaywallViewController if entitlement is not active
                    let paywallVC = PaywallViewController(programName: programName)
                    paywallVC.modalPresentationStyle = .automatic
                    self.navigationController?.present(paywallVC, animated: true, completion: nil)
                    paywallVC.onPaywallClose = {[weak self] in
                        guard let self = self else {return}
                        self.tableView.reloadData()
                    }
                }
            }
        }
        #endif
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let tableViewHeight = Double(tableView.frame.size.height - (navigationController?.navigationBar.frame.size.height)! - (tabBarController?.tabBar.frame.size.height)!)
        let rowHeight = tableViewHeight / (Double(programsArray.count) + 0.5)
        return rowHeight
    }
}

