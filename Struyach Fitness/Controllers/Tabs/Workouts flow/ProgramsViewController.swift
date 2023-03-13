//
//  ProgramsViewController.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 8/2/23.
//


import UIKit

class ProgramsViewController: UITableViewController {
    
    private let programsArray = ProgramDescriptionStorage.programArray
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavbar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
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
        cell.backgroundColor = .customDarkGray
        
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

        let programVC = SelectedProgramViewController()        
        programVC.title = programsArray[indexPath.section].programName
        navigationController?.pushViewController(programVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
       // let screenHeight = UIScreen.main.bounds.height
        let tableViewHeight = Double(tableView.frame.size.height - (navigationController?.navigationBar.frame.size.height)! - (tabBarController?.tabBar.frame.size.height)!)
        let rowHeight = tableViewHeight / (Double(programsArray.count) + 0.5)
        return rowHeight
    }
}

