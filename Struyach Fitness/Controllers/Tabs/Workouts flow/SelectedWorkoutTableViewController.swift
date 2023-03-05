//
//  SelectedWorkoutTableViewController.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 8/2/23.
//

import UIKit

class SelectedWorkoutTableViewController: UITableViewController {
    
    //MARK: - Properties
    
    private var listOfWorkouts: [Workout] = []
    private var commentsArray: [Comment] = []
    private let headerView = SelectedWorkoutHeaderView()
    private let workoutsCollection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private var selectedIntexPath: IndexPath?
    
    
    init(frame: CGRect , style: UITableView.Style) {
        super.init(style: style)
    }
//    init(frame: CGRect , style: UITableView.Style, workout: Workout) {
//        self.workout = workout
//        super.init(style: style)
//    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationAndTabBar()
        setupTableView()
        setupCollectionView()
        guard let title = title else {return}
        loadListOfWorkouts(for: title)
#if Admin
        setupAdminFunctionality()
#endif
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let title = title else {return}
        loadListOfWorkouts(for: title)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DatabaseManager.shared.deleteListener()
        
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
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        workoutsCollection.collectionViewLayout = layout
    }
    
    private func setupAdminFunctionality (){
//        setupGuestureRecognizer()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .medium)), style: .done, target: self, action: #selector(addNewWorkout))
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
            formatter.dateFormat = "EE \n d MMMM \n yyyy"
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
                if self.listOfWorkouts == [] {
                    self.headerView.workoutDescriptionTextView.text = "NO WORKOUTS ADDED YET"
                } else {
                    self.headerView.workoutDescriptionTextView.text = self.listOfWorkouts[0].description
                    print("workouts loaded")
                }
                self.tableView.reloadData()
                self.workoutsCollection.reloadData()
            }
        }
    }

    //MARK: - Methods for saving new comments to Firestore and loading them to the local commentsArray
    
    private func saveComments(workoutID: String, programID: String) {
        headerView.onSendCommentPush = {[weak self] userName, userImage, text, date in
            guard let self = self else {return}
            let timestamp = Date().timeIntervalSince1970
            let commentID = UUID().uuidString
            let newComment = Comment(timeStamp: timestamp, userName: userName, userImage: userImage, date: date, text: text, id: commentID , workoutID: workoutID, programID: programID)
            DatabaseManager.shared.addComment(comment: newComment, programID: programID) { [weak self] success in
                guard let self = self else {return}
                if success {
                    print("comment is saved to database")
                    self.loadComments(workoutID: workoutID, programID: programID )
                } else {
                    print ("cant save comment")
                }
            }
            self.headerView.commentTextView.text = ""
            self.tableView.reloadData()
        }
    }
    
    private func loadComments(workoutID: String, programID: String) {
        
        DatabaseManager.shared.getAllComments(for: workoutID, program: programID) { [weak self] comments in
            guard let self = self else {return}
            self.commentsArray = comments
            print("comments loaded, total number - \(self.commentsArray.count)")
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private func enableSnapshotListenerForComments (workoutID: String, programID: String) {
        DatabaseManager.shared.addNewCommentsListener(for: workoutID, program: programID) {[weak self] comments in
            guard let self = self else {return}
            self.commentsArray = comments
            self.tableView.reloadData()
            print("snapshot listener for new comments is on")
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
            headerView.onTextChanged = {
                tableView.performBatchUpdates(nil, completion: nil)
            }
            return headerView
        default: return nil
            
        }
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        default: return commentsArray.count
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
            cell.backgroundColor = .tertiarySystemBackground
    //        cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
}

extension SelectedWorkoutTableViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        listOfWorkouts.count

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: WorkoutsCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "workoutCell", for: indexPath) as! WorkoutsCollectionViewCell
        let workout = listOfWorkouts[indexPath.item]
        
        self.loadComments(workoutID: workout.id, programID: workout.programID)
        self.saveComments(workoutID: workout.id, programID: workout.programID)
        self.enableSnapshotListenerForComments(workoutID: workout.id, programID: workout.programID)
        
        cell.workout = workout
        cell.workoutDateLabel.backgroundColor = .systemGreen
        print("all cells are set to green")
        if indexPath.item == 0 {
            cell.workoutDateLabel.backgroundColor = .secondaryLabel
            print("the first cell is set to gray")
        }
        
        if let selectedIndexPath = selectedIntexPath, selectedIndexPath == indexPath {
            cell.workoutDateLabel.backgroundColor = .secondaryLabel
        }
        
    
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let workout = listOfWorkouts[indexPath.item]
        headerView.randomizeBackgroungImages()
        headerView.workoutDescriptionTextView.text = workout.description
        self.loadComments(workoutID: workout.id, programID: workout.programID)
        self.saveComments(workoutID: workout.id, programID: workout.programID)
        
        let selectedCell: WorkoutsCollectionViewCell = collectionView.cellForItem(at: indexPath) as! WorkoutsCollectionViewCell
        let firstIndexPath = IndexPath(item: 0, section: 0)
        if let firstCell = collectionView.cellForItem(at: firstIndexPath) as? WorkoutsCollectionViewCell{
            firstCell.workoutDateLabel.backgroundColor = .systemGreen
        }
     
        selectedCell.workoutDateLabel.backgroundColor = .secondaryLabel
        selectedIntexPath = indexPath
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell: WorkoutsCollectionViewCell = collectionView.cellForItem(at: indexPath) as? WorkoutsCollectionViewCell else {return}
        cell.workoutDateLabel.backgroundColor = .systemGreen
        
    }
}

extension SelectedWorkoutTableViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        let cellWidth = ((screenWidth - 60) / 5)
        let cellSize = CGSize(width: cellWidth, height: cellWidth)
        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
}

