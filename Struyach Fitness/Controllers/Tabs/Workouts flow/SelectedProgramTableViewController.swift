//
//  SelectedProgramTableViewController.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 8/2/23.
//

import UIKit
import FirebaseFirestore

class SelectedProgramTableViewController: UITableViewController {
    
    //MARK: - Properties
    
    private var listOfWorkouts: [Workout] = []
    private var commentsArray: [Comment] = []
    private let headerView = SelectedWorkoutHeaderView()
    private let workoutsCollection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private var selectedIndexPath: IndexPath?
    private var listener: ListenerRegistration?
    private var commentsListener: ListenerRegistration?
    
    
    init(frame: CGRect , style: UITableView.Style) {
        super.init(style: style)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //TODO: - Access data offline - when is not connected to the WEB, first give a notification, cache all the data to a copy of Firestore database and sincronize when the device is online again. read here https://firebase.google.com/docs/firestore/manage-data/enable-offline
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationAndTabBar()
        setupTableView()
        setupCollectionView()
#if Admin
        setupAdminFunctionality()
#endif
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("Executing function: \(#function)")
        guard let title = title else {return}
        loadListOfWorkouts(for: title)
        listener = DatabaseManager.shared.addWorkoutsListener(for: title) { [weak self] workouts in
            guard let self = self else { return }
            self.listOfWorkouts = workouts
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.workoutsCollection.reloadData()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("Executing function: \(#function)")
        listener?.remove()
        print ("listener is removed")
        
    }
    
    //MARK: - Methods to setup Navigation Bar, TableView and load workout data
    
    private func setupNavigationAndTabBar() {
        self.navigationController?.navigationBar.tintColor = .systemGreen
        self.tabBarController?.tabBar.isHidden = true 
    }
    
    private func setupTableView() {
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.register(CommentTableViewCell.self, forCellReuseIdentifier: String(describing: CommentTableViewCell.self))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "collectionCell")
    }
    
    private func setupCollectionView() {
        workoutsCollection.toAutoLayout()
        workoutsCollection.backgroundColor = .secondarySystemBackground
        workoutsCollection.dataSource = self
        workoutsCollection.delegate = self
        workoutsCollection.register(WorkoutsCollectionViewCell.self, forCellWithReuseIdentifier: "workoutCell")
        workoutsCollection.isScrollEnabled = true
        workoutsCollection.isUserInteractionEnabled = true
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
//        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
//        layout.minimumInteritemSpacing = 10
        workoutsCollection.collectionViewLayout = layout
    }
    
    private func setupAdminFunctionality (){
        setupGuestureRecognizer()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .medium)), style: .done, target: self, action: #selector(addNewWorkout))
    }
    
    // MARK: - Adding new workout
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
            let workoutID = UUID().uuidString
            let newWorkout = Workout(id: workoutID, programID: title, description: text, date: dateString, timestamp: timestamp)
            DatabaseManager.shared.postWorkout(with: newWorkout) {[weak self] success in
                guard let self = self else {return}
                if success {
  //                  self.loadListOfWorkouts(for: title)
                    print("workout is added to database - \(newWorkout)")
                    print("Executing function: \(#function)")
                } else {
                    self.showAlert(error: "Unable to add new workout for \(title)")
                }
            }
        }
    }
    
    private func loadListOfWorkouts(for programName: String) {
       
        DatabaseManager.shared.getAllWorkouts(for: programName) { [weak self] workouts in
            guard let self = self else {return}
            self.listOfWorkouts = workouts
            DispatchQueue.main.async {
                if self.listOfWorkouts.isEmpty {
                    self.headerView.workoutDescriptionTextView.text = "NO WORKOUTS ADDED YET"
                } else {
                    self.headerView.workoutDescriptionTextView.text = "PLEASE SELECT THE WORKOUT DATE TO SEE ITS DESCRIPTION AND LOAD COMMENTS"
                    self.tableView.reloadData()
                    self.workoutsCollection.reloadData()
                    let indexPath = IndexPath(row: 0, section: 0)
                    self.workoutsCollection.selectItem(at: indexPath, animated: true, scrollPosition: .right)
                    self.workoutsCollection.delegate?.collectionView?(self.workoutsCollection, didSelectItemAt: indexPath)
                    print("workouts loaded")
                    print("Executing function: \(#function)")
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
            let alertController = UIAlertController(title: "EDIT OR DELETE", message: "Please choose edit action, delete action, of cancel", preferredStyle: .alert)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] action in
                guard let self = self else {return}
                let workout = self.listOfWorkouts[indexPath.item]
                DatabaseManager.shared.deleteWorkout(workout: workout) { success in
         //           guard let self = self else {return}
                    if success {
       //                 self.loadListOfWorkouts(for: workout.programID)
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
                    DatabaseManager.shared.updateWorkout(workout: selectedWorkout, newDescription: text) { [weak self] success in
                        guard let self = self else {return}
                        if success{
            //                self.loadListOfWorkouts(for: selectedWorkout.programID)
                            print("Executing function: \(#function)")
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

    //MARK: - Methods for saving new comments to Firestore and loading them to the local commentsArray
    
    private func addComment(workout: Workout) {
        print("Executing function: \(#function)")
        headerView.onSendCommentPush = {[weak self] userName, userImage, text, date in
            guard let self = self else {return}
            let timestamp = Date().timeIntervalSince1970
            let commentID = UUID().uuidString
            let newComment = Comment(timeStamp: timestamp, userName: userName, userImage: userImage, date: date, text: text, id: commentID , workoutID: workout.id, programID: workout.programID)
            DatabaseManager.shared.postComment(comment: newComment) { [weak self] success in
                guard let self = self else {return}
                if success {
                    self.loadComments(programID: workout.programID, workoutID: workout.id)
                    print("comment is saved to database")
                   
                } else {
                    print ("cant save comment")
                }
            }
            self.headerView.commentTextView.text = ""
            self.tableView.reloadData()
        }
    }
    
    private func loadComments(programID: String, workoutID: String) {
        
        DatabaseManager.shared.getAllComments(programID: programID, workoutID: workoutID) { [weak self] comments in
            guard let self = self else {return}
            self.commentsArray = comments
            print ("loaded \(self.commentsArray.count) comments")
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.workoutsCollection.reloadData()
            }
        }
    }
    
    private func showAlert (error: String) {
        let alert = UIAlertController(title: "Warning", message: error, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }

    // MARK: - Table view data source methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 1:
            headerView.onTextChanged = {tableView.performBatchUpdates(nil, completion: nil)}
            return headerView
        default: return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        default:
            return commentsArray.count
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: return 100
        default: return UITableView.automaticDimension
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "collectionCell", for: indexPath)
           
            cell.contentView.addSubview(workoutsCollection)
            let constraints = [
                workoutsCollection.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
                workoutsCollection.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
                workoutsCollection.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
                workoutsCollection.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor)]
            
            NSLayoutConstraint.activate(constraints)
            return cell
            
        default:
            let cell: CommentTableViewCell = tableView.dequeueReusableCell(withIdentifier: String(describing: CommentTableViewCell.self), for: indexPath) as! CommentTableViewCell
            cell.comment = commentsArray[indexPath.row]
            cell.backgroundColor = .tertiaryLabel
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
}

extension SelectedProgramTableViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        listOfWorkouts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: WorkoutsCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "workoutCell", for: indexPath) as! WorkoutsCollectionViewCell
        let workout = listOfWorkouts[indexPath.item]

        cell.workout = workout
        if selectedIndexPath == indexPath {
                  cell.workoutDateLabel.backgroundColor = .secondaryLabel
              } else {
                  cell.workoutDateLabel.backgroundColor = .systemGreen
              }
              return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Executing function: \(#function)")
        selectedIndexPath = indexPath
        workoutsCollection.reloadData()
        let selectedWorkout = listOfWorkouts[indexPath.item]
        headerView.randomizeBackgroungImages()
        headerView.workoutDescriptionTextView.text = selectedWorkout.description
        self.addComment(workout: selectedWorkout)
        self.loadComments(programID: selectedWorkout.programID, workoutID: selectedWorkout.id)
 
        commentsListener = DatabaseManager.shared.addNewCommentsListener(workout: selectedWorkout) {[weak self] comments in
            guard let self = self else {return}
            self.commentsArray = comments
            self.tableView.reloadData()
            print("snapshot listener for new comments is on")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell: WorkoutsCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "workoutCell", for: indexPath) as! WorkoutsCollectionViewCell
        cell.workoutDateLabel.backgroundColor = .systemGreen
        commentsListener?.remove()
        print ("comments listener is removed")
    }
    
//    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        let cell: WorkoutsCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "workoutCell", for: indexPath) as! WorkoutsCollectionViewCell
//            if selectedIndexPath == indexPath {
//                cell.workoutDateLabel.backgroundColor = .secondaryLabel
//            } else {
//                cell.workoutDateLabel.backgroundColor = .systemGreen
//            }
//        }
}

extension SelectedProgramTableViewController: UICollectionViewDelegateFlowLayout {
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
}

