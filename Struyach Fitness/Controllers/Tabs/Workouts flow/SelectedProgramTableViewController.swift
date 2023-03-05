//
//  SelectedProgramTableViewController.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 8/2/23.
//


import UIKit

class SelectedProgramTableViewController: UITableViewController {
    
    private var listOfWorkouts: [Workout] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        setupNavbar()
        setupTableView()
        guard let title = self.title else {return}
        loadListOfWorkouts(for: title)
        #if Admin
        setupAdminFunctionality()
        #endif
        
        //TODO: - Access data offline - when is not connected to the WEB, first give a notification, cache all the data to a copy of Firestore database and sincronize when the device is online again. read here https://firebase.google.com/docs/firestore/manage-data/enable-offline
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let title = self.title else {return}
        DatabaseManager.shared.addSnapshotListener(for: title) {[weak self] workouts in
            guard let self = self else {return}
            self.listOfWorkouts = workouts
            self.tableView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DatabaseManager.shared.deleteListener()
    }
    
    private func setupNavbar() {
        self.navigationController?.navigationBar.largeTitleTextAttributes = [.font: UIFont.systemFont(ofSize: 25, weight: .bold)]
        self.navigationController?.navigationBar.tintColor = .systemGreen
        navigationItem.backBarButtonItem = UIBarButtonItem(title: self.title, style: .plain, target: nil, action: nil)
    }
    // Admin's app functionality allows to add new workouts, edit and delete them, when the clients' - doesn't
    private func setupAdminFunctionality (){
        setupGuestureRecognizer()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .medium)), style: .done, target: self, action: #selector(addNewWorkout))
    }
    
    private func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CellID")
    }
    
    // MARK: - Long press guesture to edit workout
    // only Admin user can edit workouts. To edit selected workout use long press guesture to open CreateNewWorkoutViewController, where the description of the workout can be edited and afterwards updated in Firestore and local array of workouts.
    
    private func setupGuestureRecognizer() {
        let longpress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        tableView.addGestureRecognizer(longpress)
    }

    @objc func handleLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let touchPoint = sender.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                let alertController = UIAlertController(title: "Edit workout", message: "Do you want to edit this workout?", preferredStyle: .alert)
                
                let editAction = UIAlertAction(title: "Yes", style: .default) { [self] action in
                    let workoutVC = CreateNewWorkoutViewController()
                    workoutVC.title = "Edit workout"
                    let selectedWorkout = listOfWorkouts[indexPath.row]
                    workoutVC.text = selectedWorkout.description
                    navigationController?.pushViewController(workoutVC, animated: true)
                    workoutVC.onWorkoutSave = { text in
                        DatabaseManager.shared.updateWorkout(program: selectedWorkout.programID, workoutID: selectedWorkout.id, newDescription: text) { [weak self] success in
                            guard let self = self else {return}
                            if success{
                                print("the workout for \(selectedWorkout.date) is successfully updated")
                                self.loadListOfWorkouts(for: selectedWorkout.programID)
                            } else {
                                self.showAlert(error: "Unable to update selected workout")
                            }
                        }
                    }
                }
                let cancelAction = UIAlertAction(title: "No", style: .cancel)
                alertController.addAction(editAction)
                alertController.addAction(cancelAction)
                alertController.view.tintColor = .darkGray
                present(alertController, animated: true)
            }
        }
    }
    
    // MARK: - Adding new workout
    // only Admin user can add new workout
    @objc private func addNewWorkout() {
        let newWorkoutVC = CreateNewWorkoutViewController()
        newWorkoutVC.title = "Add new workout"
        navigationController?.pushViewController(newWorkoutVC, animated: true)
        newWorkoutVC.onWorkoutSave = {[weak self] text in
            guard let title = self?.title else {return}
            let timestamp = Date().timeIntervalSince1970
            let date = Date(timeIntervalSince1970: timestamp)
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, d MMMM, yyyy"
            let dateString = formatter.string(from: date)
            let workoutID = UUID().uuidString
            let newWorkout = Workout(id: workoutID, programID: title, description: text, date: dateString, timestamp: timestamp)
            DatabaseManager.shared.postWorkout(with: newWorkout, programID: title) {[weak self] success in
                guard let self = self else {return}
                if success {
                    self.loadListOfWorkouts(for: title)
                } else {
                    self.showAlert(error: "Unable to add new workout for \(title)")
                }
            }
        }
    }
    
    private func loadListOfWorkouts( for programName: String) {
        DatabaseManager.shared.getAllWorkouts(for: programName) { [weak self] workouts in
            guard let self = self else {return}
            self.listOfWorkouts = workouts
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private func showAlert (error: String) {
        let alert = UIAlertController(title: "Warning", message: error, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }

    // MARK: - Table view data source and delegate methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfWorkouts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellID", for: indexPath)
        
        let workout = listOfWorkouts[indexPath.row]
        cell.tintColor = .black
        cell.backgroundColor = .tertiarySystemBackground
        cell.textLabel?.text = "Workout for \(workout.date)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        #if Admin
        return true
        #else
        return false
        #endif
    }
    
    // MARK: - Deleting selected workout from Firestore and local array of workouts
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let workout = listOfWorkouts[indexPath.row]
            DatabaseManager.shared.deleteWorkout(program: workout.programID, workoutID: workout.id) { [weak self] success in
                guard let self = self else {return}
                if success {
                    self.loadListOfWorkouts(for: workout.programID)
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
  //      let selectedWorkout = listOfWorkouts[indexPath.row]
 //       let selectedWorkoutVC = SelectedWorkoutTableViewController(frame: .zero, style: .grouped, workout: selectedWorkout)
//        selectedWorkoutVC.view.backgroundColor = .secondarySystemBackground
//        navigationController?.navigationBar.prefersLargeTitles = true
//        navigationController?.pushViewController(selectedWorkoutVC, animated: true)
//        tableView.deselectRow(at: indexPath, animated: true)
//        self.tableView.reloadData()
    }
}
