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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavbar()
    }
    
    private func setupTableView () {
        tableView.backgroundColor = .systemTeal
        tableView.register(ProgramTableViewCell.self, forCellReuseIdentifier: String(describing: ProgramTableViewCell.self))
        tableView.isScrollEnabled = false
    }
    
    private func setupNavbar() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Programs", style: .plain, target: nil, action: nil)
        self.navigationController?.navigationBar.largeTitleTextAttributes = [.font: UIFont.systemFont(ofSize: 34, weight: .bold)]
    }
    
    //MARK: - Table View datasource and delegate methods
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ProgramTableViewCell = tableView.dequeueReusableCell(withIdentifier: String(describing: ProgramTableViewCell.self), for: indexPath) as! ProgramTableViewCell
        
        cell.program = programsArray[indexPath.section]
        cell.backgroundView?.alpha = 0.3
        
        
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
        view.backgroundColor = .systemTeal
        return view
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

            let selectedProgramVC = SelectedProgramTableViewController()
            selectedProgramVC.title = programsArray[indexPath.section].programName
            navigationController?.pushViewController(selectedProgramVC, animated: true)
            tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let tableViewHeight = Double(tableView.frame.size.height - (navigationController?.navigationBar.frame.size.height)! - (tabBarController?.tabBar.frame.size.height)!)
        
        return tableViewHeight / (Double(programsArray.count) + 0.5)
    }
}

