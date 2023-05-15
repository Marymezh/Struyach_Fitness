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
    private let programsDescriptionArray = ["Get fit and toned with our Bodyweight Training Plan - no equipment needed, perfect for on-the-go workouts!".localized(), "Transform your body with our ECD Plan - designed for gym or CrossFit box training".localized(), "Take your training to the next level with our Struyach Plan - designed specifically for experienced athletes".localized(), "Tone and strengthen your pelvic muscles with our 10 high-intensity workouts".localized(), "Get rid of stubborn belly fat and achieve a leaner, fitter body with our 10 high-intensity workouts".localized()]
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
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .cancel)
        alert.addAction(cancelAction)
        alert.view.tintColor = .systemGreen
        self.present(alert, animated: true, completion: nil)
    }
    
   
    //MARK: - Table View datasource and delegate methods
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ProgramTableViewCell = tableView.dequeueReusableCell(withIdentifier: String(describing: ProgramTableViewCell.self), for: indexPath) as! ProgramTableViewCell
        
        cell.program = programsArray[indexPath.section]
        cell.program?.programDetail = programsDescriptionArray[indexPath.section]
        
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
                    //Push WorkoutsVC if user is subscribed
                    let programVC = WorkoutsViewController()
                    programVC.title = programName
                    self.navigationController?.pushViewController(programVC, animated: true)
                } else {
                    // Present PaywallViewController if user is not subscribed
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

