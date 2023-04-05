//
//  BlogTableViewController.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 5/4/23.
//

import UIKit

class BlogTableViewController: UITableViewController {
    
    private var blogPosts: [Post] = []
    
   
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        setupAdminFunctionality()
    }
    
    private func setupTableView() {
        tableView.backgroundColor = .customDarkGray
        tableView.register(ProfileTableViewCell.self, forCellReuseIdentifier: String(describing: BlogTableViewCell.self))
    }
    
    private func setupAdminFunctionality (){
        self.navigationItem.rightBarButtonItem =
            UIBarButtonItem(image: UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .medium)), style: .done, target: self, action: #selector(addNewPost))
    }
    
    @objc private func addNewPost() {
        print("Executing function: \(#function)")
        let newWorkoutVC = CreateNewWorkoutViewController()
        newWorkoutVC.title = "Add new post"
        navigationController?.pushViewController(newWorkoutVC, animated: true)
        newWorkoutVC.onWorkoutSave = {[weak self] text in
            guard let title = self?.title else {return}
            let timestamp = Date().timeIntervalSince1970
            let date = Date(timeIntervalSince1970: timestamp)
            let formatter = DateFormatter()
            formatter.dateFormat = "EE \n d MMMM \n yyyy"
            let dateString = formatter.string(from: date)
            let workoutID = dateString.replacingOccurrences(of: " ", with: "_") + (UUID().uuidString)
            let newWorkout = Workout(id: workoutID, programID: title, description: text, date: dateString, timestamp: timestamp)
            DatabaseManager.shared.postWorkout(with: newWorkout) {[weak self] success in
                print("Executing function: \(#function)")
                guard let self = self else {return}
                if success {
                    print("workout is added to database - \(newWorkout)")
                } else {
                    self.showAlert(error: "Unable to add new workout for \(title)")
                }
            }
        }
    }
    
    private func showAlert (error: String) {
        let alert = UIAlertController(title: "Warning", message: error, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return blogPosts.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: BlogTableViewCell = tableView.dequeueReusableCell(withIdentifier: String(describing: BlogTableViewCell.self), for: indexPath) as! BlogTableViewCell
        

        return cell
    }
    

  
}
