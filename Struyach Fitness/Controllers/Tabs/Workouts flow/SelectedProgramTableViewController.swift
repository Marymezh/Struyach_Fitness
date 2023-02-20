//
//  SelectedProgramTableViewController.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 8/2/23.
//


import UIKit

class SelectedProgramTableViewController: UITableViewController {
    
    private var numberOfWorkouts: Int = 0
    private var listOfWorkouts: [WorkoutDescription] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "darkGreen")
        setupNavbar()
        setupTableView()
        #if Admin
        setupGuestureRecognizer()
        #endif
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadWorkoutsList()
        tableView.reloadData()

    }
    
    private func setupNavbar() {
        self.navigationController?.navigationBar.largeTitleTextAttributes = [.font: UIFont.systemFont(ofSize: 25, weight: .bold)]
        self.navigationController?.navigationBar.tintColor = .black
        // Admin's app functionality allows to add new workouts, when the clients' - doesn't
        #if Admin
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .medium)), style: .done, target: self, action: #selector(addNewWorkout))
        #else
        #endif
        navigationItem.backBarButtonItem = UIBarButtonItem(title: self.title, style: .plain, target: nil, action: nil)
    }
    
    private func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CellID")
    }
    
    private func loadWorkoutsList() {
        switch self.title {
        case "ECD/BEFIT TRAINING PLAN":
            listOfWorkouts = WorkoutDescriptionStorage.ecd
        case "BODYWEIGHT PLAN":
            listOfWorkouts = WorkoutDescriptionStorage.bodyweight
        case " 'STRUYACH' PLAN":
            listOfWorkouts = WorkoutDescriptionStorage.struyach
        case "BADASS":
            listOfWorkouts = WorkoutDescriptionStorage.badass
        case "HARD PRESS":
            listOfWorkouts = WorkoutDescriptionStorage.hardpress
        default: fatalError("Unable to load workout description")
        }
        numberOfWorkouts = listOfWorkouts.count
    }
    
    // MARK: - Long press guesture to edit workout
    
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
                    workoutVC.text = listOfWorkouts[indexPath.row].description
                    navigationController?.pushViewController(workoutVC, animated: true)
                    workoutVC.onWorkoutSave = { text in
                        switch self.title {
                        case "ECD/BEFIT TRAINING PLAN": WorkoutDescriptionStorage.ecd[indexPath.row].description = text
                        case "BODYWEIGHT PLAN": WorkoutDescriptionStorage.bodyweight[indexPath.row].description = text
                        case " 'STRUYACH' PLAN": WorkoutDescriptionStorage.struyach[indexPath.row].description = text
                        case "BADASS": WorkoutDescriptionStorage.badass[indexPath.row].description = text
                        case "HARD PRESS": WorkoutDescriptionStorage.hardpress[indexPath.row].description = text
                        default: fatalError("Unable to edit workout")
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
    
    @objc private func addNewWorkout() {
        let newWorkoutVC = CreateNewWorkoutViewController()
        newWorkoutVC.title = "Add new workout"
        navigationController?.pushViewController(newWorkoutVC, animated: true)
        newWorkoutVC.onWorkoutSave = {[weak self] text in
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM yyyy"
            let date = formatter.string(from: Date())
            switch self?.title {
            case "ECD/BEFIT TRAINING PLAN": WorkoutDescriptionStorage.ecd.insert(WorkoutDescription(description: text, date: date), at: 0)
            case "BODYWEIGHT PLAN": WorkoutDescriptionStorage.bodyweight.insert(WorkoutDescription(description: text, date: date), at: 0)
            case " 'STRUYACH' PLAN": WorkoutDescriptionStorage.struyach.insert(WorkoutDescription(description: text, date: date), at: 0)
            case "BADASS": WorkoutDescriptionStorage.badass.insert(WorkoutDescription(description: text, date: date), at: 0)
            case "HARD PRESS": WorkoutDescriptionStorage.hardpress.insert(WorkoutDescription(description: text, date: date), at: 0)
            default: fatalError("Unable to identify category of workout")
            }
        }
    }

    // MARK: - Table view data source and delegate methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfWorkouts
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellID", for: indexPath)
        
        cell.tintColor = .black
        cell.backgroundColor = UIColor(named: "lightGreen")
        cell.textLabel?.text = "Workout for \(listOfWorkouts[indexPath.row].date)"

        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        #if Admin
        return true
        #else
        return false
        #endif
    }
    // TODO: - fix removing logics, now it's deleteng only from local listOfWorkouts, but not from the storage
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            listOfWorkouts.remove(at: indexPath.row)
            switch self.title {
            case "ECD/BEFIT TRAINING PLAN": WorkoutDescriptionStorage.ecd.remove(at: indexPath.row)
            case "BODYWEIGHT PLAN": WorkoutDescriptionStorage.bodyweight.remove(at: indexPath.row)
            case " 'STRUYACH' PLAN": WorkoutDescriptionStorage.struyach.remove(at: indexPath.row)
            case "BADASS": WorkoutDescriptionStorage.badass.remove(at: indexPath.row)
            case "HARD PRESS": WorkoutDescriptionStorage.hardpress.remove(at: indexPath.row)
            default: fatalError("Unable to delete workout")
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
            numberOfWorkouts = listOfWorkouts.count
            tableView.endUpdates()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedWorkoutVC = SelectedWorkoutTableViewController(frame: .zero, style: .grouped)
        
        selectedWorkoutVC.title = "Workout for \(listOfWorkouts[indexPath.row].date)"
        
        selectedWorkoutVC.headerView.workoutDescriptionTextView.text = listOfWorkouts[indexPath.row].description
        
        selectedWorkoutVC.onCompletion = {
            self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        navigationController?.pushViewController(selectedWorkoutVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
        self.tableView.reloadData()
    }
}
