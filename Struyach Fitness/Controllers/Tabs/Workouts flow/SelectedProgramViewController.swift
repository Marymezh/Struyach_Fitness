//
//  SelectedProgramTableViewController.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 8/2/23.
//

import UIKit
import FirebaseFirestore

class SelectedProgramViewController: UIViewController {
    
    //MARK: - Properties
    
    private var listOfWorkouts: [Workout] = []
    private var filteredWorkouts: [Workout] = []
    private let selectedWorkoutView = SelectedWorkoutView()
    private let workoutsCollection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private var selectedIndexPath: IndexPath?
    private var baseInset: CGFloat { return 15 }
    private var selectedWorkout: Workout?
    private var searchBarConstraint: NSLayoutConstraint?
   
    
    private lazy var addCommentButton: UIButton = {
        let button = UIButton()
        button.toAutoLayout()
        button.tintColor = .white
        button.setImage(UIImage(systemName: "message", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .medium)), for: .normal)
        button.addTarget(self, action: #selector(pushCommentsVC), for: .touchUpInside)
        return button
    }()

    private let commentsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .white
        label.toAutoLayout()
        return label
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for workouts"
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundColor = .customDarkGray
        searchBar.searchTextField.textColor = .customDarkGray
        searchBar.searchTextField.backgroundColor = .white
        searchBar.barTintColor = .customDarkGray
        searchBar.tintColor = .customDarkGray
        searchBar.clipsToBounds = true
        searchBar.showsSearchResultsButton = true
        searchBar.isHidden = true
        searchBar.toAutoLayout()
        return searchBar
    }()
    
    //TODO: - Access data offline - when is not connected to the WEB, first give a notification, cache all the data to a copy of Firestore database and sincronize when the device is online again. read here https://firebase.google.com/docs/firestore/manage-data/enable-offline
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
        setupNavigationAndTabBar()
        setupCollectionView()
        setupSubviews()
#if Admin
        setupAdminFunctionality()
#endif
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("Executing function: \(#function)")
        
        guard let title = title else {return}
        loadListOfWorkouts(for: title)

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("Executing function: \(#function)")
        searchBarCancelButtonClicked(searchBar)
    }
    
    //MARK: - Methods to setup Navigation Bar, TableView and load workout data
    
    private func setupNavigationAndTabBar() {
        navigationController?.navigationBar.tintColor = .systemGreen
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .medium)), style: .done, target: self, action: #selector(toggleSearchBar))
        tabBarController?.tabBar.isHidden = true
    }
    
    private func setupSubviews(){
        view.backgroundColor = .customDarkGray
        selectedWorkoutView.toAutoLayout()
        view.addSubviews(searchBar, workoutsCollection, selectedWorkoutView, addCommentButton, commentsLabel)
        
        searchBarConstraint = searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -44)
        
        let constraints = [
            searchBarConstraint!,
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            searchBar.heightAnchor.constraint(equalToConstant: 44),
        
            workoutsCollection.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 15),
            workoutsCollection.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            workoutsCollection.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            workoutsCollection.heightAnchor.constraint(equalToConstant: 90),

            selectedWorkoutView.topAnchor.constraint(equalTo: workoutsCollection.bottomAnchor, constant: baseInset),
            selectedWorkoutView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            selectedWorkoutView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            selectedWorkoutView.bottomAnchor.constraint(equalTo: addCommentButton.topAnchor, constant: -baseInset),
            
            addCommentButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: baseInset),
            addCommentButton.widthAnchor.constraint(equalToConstant: 35),
            addCommentButton.heightAnchor.constraint(equalToConstant: 35),
            addCommentButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -baseInset*2),
            
            commentsLabel.topAnchor.constraint(equalTo: addCommentButton.topAnchor),
            commentsLabel.leadingAnchor.constraint(equalTo: addCommentButton.trailingAnchor, constant: baseInset*2),
            commentsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -baseInset),
            commentsLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -baseInset*2),
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setupCollectionView() {
        workoutsCollection.toAutoLayout()
        workoutsCollection.backgroundColor = .customDarkGray
        workoutsCollection.dataSource = self
        workoutsCollection.delegate = self
        workoutsCollection.register(WorkoutsCollectionViewCell.self, forCellWithReuseIdentifier: "workoutCell")
        workoutsCollection.isScrollEnabled = true
        workoutsCollection.isUserInteractionEnabled = true
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        workoutsCollection.collectionViewLayout = layout
    }
    
    private func setupAdminFunctionality (){
        setupGuestureRecognizer()
        self.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .medium)), style: .done, target: self, action: #selector(addNewWorkout)),
            UIBarButtonItem(image: UIImage(systemName: "magnifyingglass", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .medium)), style: .done, target: self, action: #selector(toggleSearchBar))
        ]
    }
    
    @objc private func pushCommentsVC() {
        guard let selectedWorkout = selectedWorkout else { print("workout is not selected")
            return }
        let commentsVC = CommentsViewController(workout: selectedWorkout)
        navigationController?.pushViewController(commentsVC, animated: true)
    }
    
    @objc private func toggleSearchBar() {
        searchBar.isHidden = !searchBar.isHidden
        
        if searchBar.isHidden {
            searchBarConstraint?.constant = -searchBar.frame.size.height
        } else {
            searchBarConstraint?.constant = 0
        }
    }
    
    // MARK: - Adding new workout and loading list of workouts
    // only Admin user can add new workout
    @objc private func addNewWorkout() {
        print("Executing function: \(#function)")
        let newWorkoutVC = CreateNewWorkoutViewController()
        newWorkoutVC.title = "Add new workout"
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
    
    private func loadListOfWorkouts(for programName: String) {
       
        DatabaseManager.shared.getAllWorkouts(for: programName) { [weak self] workouts in
            print("Executing function: \(#function)")
            guard let self = self else {return}
            self.listOfWorkouts = workouts
            self.filteredWorkouts = self.listOfWorkouts
         
            DispatchQueue.main.async {
                if self.listOfWorkouts.isEmpty {
                    self.workoutsCollection.reloadData()
                    print("no workouts")
                    self.selectedWorkoutView.workoutDescriptionTextView.text = "No workouts found for this program"
                } else {
                    if self.selectedIndexPath != nil {
                        self.workoutsCollection.reloadData()
                        self.workoutsCollection.selectItem(at: self.selectedIndexPath!, animated: true, scrollPosition: .right)
                        self.workoutsCollection.delegate?.collectionView?(self.workoutsCollection, didSelectItemAt: self.selectedIndexPath!)
                        print("select workout at selected indexPath")
                    } else {
                        self.workoutsCollection.reloadData()
                        let indexPath = IndexPath(row: 0, section: 0)
                        self.workoutsCollection.selectItem(at: indexPath, animated: true, scrollPosition: .right)
                        self.workoutsCollection.delegate?.collectionView?(self.workoutsCollection, didSelectItemAt: indexPath)
                        print("select first item in collection")
                    }
                }
            }
        }
    }
    
    private func setupGuestureRecognizer() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        workoutsCollection.addGestureRecognizer(longPress)
    }
    
    @objc func handleLongPress(sender: UILongPressGestureRecognizer) {
        print("Executing function: \(#function)")
        let location = sender.location(in: workoutsCollection)
        if let indexPath = workoutsCollection.indexPathForItem(at: location) {
            let alertController = UIAlertController(title: "EDIT OR DELETE", message: "Please choose edit action, delete action, of cancel", preferredStyle: .actionSheet)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] action in
                guard let self = self else {return}
                let workout = self.listOfWorkouts[indexPath.item]
                DatabaseManager.shared.deleteWorkout(workout: workout) { success in
                    if success {
                        DatabaseManager.shared.getAllWorkouts(for: workout.programID) { [weak self] workouts in
                            print("Executing function: \(#function)")
                            guard let self = self else {return}
                            self.listOfWorkouts = workouts
                            self.filteredWorkouts = self.listOfWorkouts
                            self.workoutsCollection.reloadData()
                            
                            if self.listOfWorkouts.isEmpty {
                                self.selectedWorkoutView.workoutDescriptionTextView.text = "No workouts found for this program"
                            } else {
                                self.selectedWorkoutView.workoutDescriptionTextView.text = "Workout successfully deleted"
                            }
                        }
                        print("workout is deleted")
                    } else {
                        print ("can not delete workout")
                    }
                }
            }
            let editAction = UIAlertAction(title: "Edit", style: .default) { [weak self] action in
                guard let self = self else {return}
                let workoutVC = CreateNewWorkoutViewController()
                workoutVC.title = "Edit workout"
                let selectedWorkout = self.listOfWorkouts[indexPath.item]
                workoutVC.text = selectedWorkout.description
                self.navigationController?.pushViewController(workoutVC, animated: true)
                workoutVC.onWorkoutSave = { text in
                    DatabaseManager.shared.updateWorkout(workout: selectedWorkout, newDescription: text) { success in
                        if success{
                            print("workout is successfully updated")
                            self.selectedWorkoutView.workoutDescriptionTextView.text = text
                          //  self.loadListOfWorkouts(for: selectedWorkout.programID)
                        } else {
                            self.showAlert(error: "Unable to update selected workout")
                        }
                    }
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            alertController.addAction(editAction)
            alertController.addAction(deleteAction)
            alertController.addAction(cancelAction)
            alertController.view.tintColor = .darkGray
            present(alertController, animated: true)
        }
    }

    private func showAlert (error: String) {
        let alert = UIAlertController(title: "Warning", message: error, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
}

extension SelectedProgramViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
   //     listOfWorkouts.count
        filteredWorkouts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: WorkoutsCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "workoutCell", for: indexPath) as! WorkoutsCollectionViewCell
//        let workout = listOfWorkouts[indexPath.item]
        let workout = filteredWorkouts[indexPath.item]
        cell.workout = workout
        updateCellColor(cell, isSelected: indexPath == selectedIndexPath)
            return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Executing function: \(#function)")
        if let selectedIndexPath = selectedIndexPath {
            collectionView.deselectItem(at: selectedIndexPath, animated: true)
        }
        
        selectedIndexPath = indexPath
        DispatchQueue.main.async {
            self.workoutsCollection.reloadData()
        }
        
        //   let selectedWorkout = listOfWorkouts[indexPath.item]
        guard let safeIndexPath = selectedIndexPath else {print ("no index path")
            return
        }
        let selectedWorkout = filteredWorkouts[safeIndexPath.item]
        self.selectedWorkout = selectedWorkout
        selectedWorkoutView.randomizeBackgroungImages()
        selectedWorkoutView.workoutDescriptionTextView.text = selectedWorkout.description
        
        DatabaseManager.shared.getAllComments(workout: selectedWorkout) { [weak self] comments in
            print("found \(comments.count) comments for selected workout")
            DispatchQueue.main.async {
                switch comments.count {
                case 0: self?.commentsLabel.text = "No comments posted yet"
                case 1: self?.commentsLabel.text = "Read \(comments.count) comment "
                default: self?.commentsLabel.text = "Read all \(comments.count) comments"
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        print("Executing function: \(#function)")
        if indexPath == selectedIndexPath {
                selectedIndexPath = nil
            }
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = cell as! WorkoutsCollectionViewCell
           updateCellColor(cell, isSelected: indexPath == selectedIndexPath)
    }
}

extension SelectedProgramViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = collectionView.bounds.width
        let cellWidth = ((screenWidth - 60) / 5)
        let cellSize = CGSize(width: cellWidth, height: cellWidth)
        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
            return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func updateCellColor(_ cell: WorkoutsCollectionViewCell, isSelected: Bool) {
        if isSelected {
            cell.workoutDateLabel.backgroundColor = .customMediumGray
        } else {
            cell.workoutDateLabel.backgroundColor = .systemGreen
        }
    }
}

extension SelectedProgramViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let searchQuery = searchText
        if searchQuery.isEmpty {
            filteredWorkouts = listOfWorkouts
            selectedWorkoutView.workoutDescriptionTextView.text = selectedWorkout?.description
        } else {
            filteredWorkouts = listOfWorkouts.filter { $0.description.localizedCaseInsensitiveContains(searchQuery)}
            if filteredWorkouts.isEmpty == true {
                selectedWorkoutView.workoutDescriptionTextView.text = "Ooops! No workouts were found! Change your query and try again."
            } else {
            selectedWorkoutView.workoutDescriptionTextView.text = "Select workout from search results."
            }
        }
        workoutsCollection.reloadData()
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        filteredWorkouts = listOfWorkouts

        workoutsCollection.reloadData()
        searchBar.resignFirstResponder()
    }
}

