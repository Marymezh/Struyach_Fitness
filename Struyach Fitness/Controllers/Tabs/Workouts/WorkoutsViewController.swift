//
//  SelectedProgramTableViewController.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 8/2/23.
//

import UIKit
import FirebaseFirestore

class WorkoutsViewController: UIViewController {
    
    //MARK: - Properties
    
    private var listOfWorkouts: [Workout] = []
    private var filteredWorkouts: [Workout] = []
    private let selectedWorkoutView = SelectedWorkoutView()
    private let workoutsCollection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private var selectedIndexPath: IndexPath?
    private var baseInset: CGFloat { return 15 }
    private var selectedWorkout: Workout?
    private var searchBarConstraint: NSLayoutConstraint?
    private var likedWorkouts = UserDefaults.standard.array(forKey: "likedWorkouts") as? [String] ?? []
    private let pageSize = 10
    private var lastDocumentSnapshot: DocumentSnapshot? = nil
    private var isFetching = false
    private var shouldLoadMorePosts = true
    private var workoutsListener: ListenerRegistration?
   
    private lazy var addCommentButton: UIButton = {
        let button = UIButton()
        button.toAutoLayout()
        button.tintColor = .white
        button.setImage(UIImage(systemName: "message", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .medium)), for: .normal)
        button.addTarget(self, action: #selector(pushCommentsVC), for: .touchUpInside)
        return button
    }()
    
    private lazy var likeButton: UIButton = {
        let button = UIButton()
        button.toAutoLayout()
        button.tintColor = .white
        button.setImage(UIImage(systemName: "heart", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .medium)), for: .normal)
        button.addTarget(self, action: #selector(addLikeToWorkout), for: .touchUpInside)
        return button
    }()
    
    private let likesLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .white
        label.text = "0"
        label.toAutoLayout()
        return label
    }()

    private let commentsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .white
        label.toAutoLayout()
        return label
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .equalSpacing
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.toAutoLayout()
        return stackView
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
        searchBar.showsCancelButton = true
        searchBar.isHidden = true
        searchBar.toAutoLayout()
        return searchBar
    }()
    
    private lazy var plusButton: UIButton = {
       let button = UIButton()
        button.setImage(UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .medium)), for: .normal)
        button.backgroundColor = .systemGreen
        button.tintColor = .white
        button.addTarget(self, action: #selector(addNewWorkout), for: .touchUpInside)
        button.layer.cornerRadius = 30
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowRadius = 30
        button.layer.shadowOffset = CGSize(width: 5, height: 5)
        button.layer.shadowOpacity = 0.6
        button.isHidden = true
        button.toAutoLayout()
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
        setupNavigationAndTabBar()
        setupCollectionView()
        setupSubviews()
#if Admin
        setupAdminFunctionality()
#endif
        setupSearchBarCancelButton()
        guard let title = title else {return}
        self.loadWorkoutsWithPagination(program: title, pageSize: self.pageSize)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("Executing function: \(#function)")
        navigationController?.navigationBar.prefersLargeTitles = true
        DatabaseManager.shared.allWorkoutsLoaded = false
        guard let title = title else {return}
        workoutsListener = DatabaseManager.shared.addWorkoutsListener(for: title) { [weak self] updatedWorkouts in
            guard let self = self else {return}
            self.listOfWorkouts = updatedWorkouts
            self.filteredWorkouts = self.listOfWorkouts
            self.workoutsCollection.reloadData()
            print ("workouts updated, total number of workouts - \(updatedWorkouts.count)")
            if self.selectedWorkout != nil {
                for updatedWorkout in updatedWorkouts {
                    if updatedWorkout.id == self.selectedWorkout!.id {
                        self.selectedWorkout = updatedWorkout
                        DispatchQueue.main.async {
                            self.updateUI(workout: self.selectedWorkout!)
                            self.workoutsCollection.reloadData()
                            print ("selected workout updated")
                        }
                        break
                    }
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("Executing function: \(#function)")
        workoutsListener?.remove()
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
        view.addSubviews(searchBar, workoutsCollection, selectedWorkoutView, stackView, plusButton)
        stackView.addArrangedSubview(likeButton)
        stackView.addArrangedSubview(likesLabel)
        stackView.addArrangedSubview(addCommentButton)
        stackView.addArrangedSubview(commentsLabel)
        
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
            selectedWorkoutView.bottomAnchor.constraint(equalTo: stackView.topAnchor, constant: -baseInset),
            
            likeButton.widthAnchor.constraint(equalToConstant: 35),
            likeButton.heightAnchor.constraint(equalTo: likeButton.widthAnchor),
            likesLabel.leadingAnchor.constraint(equalTo: likeButton.trailingAnchor, constant: baseInset),
            likesLabel.widthAnchor.constraint(equalTo: likeButton.widthAnchor),
            addCommentButton.widthAnchor.constraint(equalToConstant: 35),
            addCommentButton.heightAnchor.constraint(equalToConstant: 35),
            commentsLabel.leadingAnchor.constraint(equalTo: addCommentButton.trailingAnchor, constant: baseInset),
            
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: baseInset),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -baseInset*2),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -baseInset),
            
            plusButton.bottomAnchor.constraint(equalTo: selectedWorkoutView.bottomAnchor, constant: -25),
            plusButton.trailingAnchor.constraint(equalTo: selectedWorkoutView.trailingAnchor, constant: -25),
            plusButton.widthAnchor.constraint(equalToConstant: 60),
            plusButton.heightAnchor.constraint(equalTo: plusButton.widthAnchor)
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
        plusButton.isHidden = false
    }
    
    private func clearUI() {
        likesLabel.text = "0"
        likeButton.isSelected = false
        likeButton.setImage(UIImage(systemName: "heart", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .medium)), for: .normal)
        likeButton.tintColor = .white
        commentsLabel.text = "No comments posted yet"
    }
    
    private func updateUI(workout: Workout) {
        selectedWorkoutView.workoutDescriptionTextView.text = workout.description
        likesLabel.text = "\(workout.likes)"
        switch workout.comments {
        case 0: commentsLabel.text = "No comments posted yet"
        case 1: commentsLabel.text = "1 comment "
        default: commentsLabel.text = "\(workout.comments) comments"
        }
    }
    
    // MARK: - Adding new workout and loading list of workouts
    // only Admin user can add new workout
    @objc private func addNewWorkout() {
        print("Executing function: \(#function)")
        let newWorkoutVC = TextViewController()
        newWorkoutVC.title = "Add new workout"
        navigationController?.pushViewController(newWorkoutVC, animated: true)
        newWorkoutVC.onWorkoutSave = {[weak self] text in
            guard let title = self?.title else {return}
            let timestamp = Date().timeIntervalSince1970
            let date = Date(timeIntervalSince1970: timestamp)
            let formatter = DateFormatter()
            formatter.dateFormat = "EE \n d MMM \n yyyy"
            let dateString = formatter.string(from: date)
            let workoutID = dateString.replacingOccurrences(of: " ", with: "_") + (UUID().uuidString)
            let newWorkout = Workout(id: workoutID, programID: title, description: text, date: dateString, timestamp: timestamp, likes: 0)
            DatabaseManager.shared.postWorkout(with: newWorkout) {[weak self] success in
                print("Executing function: \(#function)")
                guard let self = self else {return}
                if success {
                    let indexPath = IndexPath(row: 0, section: 0)
                    self.workoutsCollection.selectItem(at: indexPath, animated: true, scrollPosition: .right)
                    self.workoutsCollection.delegate?.collectionView?(self.workoutsCollection, didSelectItemAt: indexPath)
                } else {
                    self.showAlert(title: "Warning", message: "Unable to post new workout")
                }
            }
        }
    }
    
    private func loadWorkoutsWithPagination(program: String, pageSize: Int){
        print ("executing function \(#function)")
        guard !isFetching else { return }
        isFetching = true
        DatabaseManager.shared.getWorkoutsWithPagination(program: program, pageSize: pageSize, startAfter: lastDocumentSnapshot) { [weak self] workouts, lastDocumentSnapshot in
            guard let self = self else { return }
            
            if self.lastDocumentSnapshot == nil {
                self.listOfWorkouts = workouts
                self.filteredWorkouts = self.listOfWorkouts
                self.workoutsCollection.reloadData()
                print("load first bunch of workouts")
                print(self.listOfWorkouts.count)
                
                switch self.listOfWorkouts.isEmpty {
                case true: self.workoutsCollection.reloadData()
                    self.selectedWorkoutView.workoutDescriptionTextView.text = "No workouts found for this program"
                case false:
                    let indexPath = IndexPath(row: 0, section: 0)
                    self.workoutsCollection.selectItem(at: indexPath, animated: true, scrollPosition: .right)
                    self.workoutsCollection.delegate?.collectionView?(self.workoutsCollection, didSelectItemAt: indexPath)
                }
            } else {
                print("load next bunch of workouts")
                self.listOfWorkouts.append(contentsOf: workouts)
                self.filteredWorkouts = self.listOfWorkouts
                self.workoutsCollection.reloadData()
                print(self.listOfWorkouts.count)
            }
            self.lastDocumentSnapshot = lastDocumentSnapshot
            self.workoutsCollection.reloadData()
            self.isFetching = false
        }
    }
    
    // MARK: - Long press setup for admin to delete and update workouts
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
                DatabaseManager.shared.deleteWorkout(workout: workout) {[weak self] success in
                    guard let self = self else { return }
                    if success {
                        self.clearUI()
                        print ("number of workouts left - \(self.listOfWorkouts.count)")
                        switch self.listOfWorkouts.isEmpty {
                        case true:
                            self.selectedWorkoutView.workoutDescriptionTextView.text = "No workouts found for this program"
                        case false:
                            self.selectedWorkoutView.workoutDescriptionTextView.text = "Workout successfully deleted"
                        }
                    } else {
                        self.showAlert(title: "Warning", message: "Unable to delete this workout")
                    }
                }
            }
            
            let editAction = UIAlertAction(title: "Edit", style: .default) { [weak self] action in
                guard let self = self else {return}
                let workoutVC = TextViewController()
                workoutVC.title = "Edit workout"
                let selectedWorkout = self.listOfWorkouts[indexPath.item]
                workoutVC.text = selectedWorkout.description
                self.navigationController?.pushViewController(workoutVC, animated: true)
                workoutVC.onWorkoutSave = {[weak self] text in
                    guard let self = self else {return}
                    DatabaseManager.shared.updateWorkout(workout: selectedWorkout, newDescription: text) { [weak self] workout in
                        guard let self = self else {return}
                        let workoutDate = workout.date.replacingOccurrences(of: "\n", with: "")
                        self.showAlert(title: "Success", message: "Workout for \(workoutDate) is successfully updated!")
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
    
    @objc private func pushCommentsVC() {
        guard let selectedWorkout = selectedWorkout else { print("workout is not selected")
            return }
        let commentsVC = CommentsViewController(workout: selectedWorkout)
        commentsVC.title = "Comments"
        navigationController?.pushViewController(commentsVC, animated: true)
        
        commentsVC.onCommentsClose = {
            DatabaseManager.shared.getCommentsCount(workout: selectedWorkout) { [weak self] numberOfComments in
                DatabaseManager.shared.updateWorkoutCommentsCount(workout: selectedWorkout, commentsCount: numberOfComments) { [weak self] workout in
                    guard let self = self else {return}
                    print ("number of workout comments is \(workout.comments)")
                    if let index = self.filteredWorkouts.firstIndex(where: { $0.id == workout.id }) {
                        self.filteredWorkouts[index] = workout
                        switch workout.comments {
                        case 0: self.commentsLabel.text = "No comments posted yet"
                        case 1: self.commentsLabel.text = "\(workout.comments) comment "
                        default: self.commentsLabel.text = "\(workout.comments) comments"
                        }
                    }
                }
            }
        }
    }
    
    //MARK: - Methods to handle likes and toggle search bar
    private func hasUserLikedWorkout(workout: Workout) -> Bool {
        return self.likedWorkouts.contains(workout.id)
    }
    
    @objc private func addLikeToWorkout() {
        likeButton.isSelected = !likeButton.isSelected
        guard var selectedWorkout = selectedWorkout,
              let index = listOfWorkouts.firstIndex(where: {$0 == selectedWorkout}) else {return}
        
        if likeButton.isSelected {
            likeButton.setImage(UIImage(systemName: "heart.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .medium)), for: .normal)
            likeButton.tintColor = .systemRed
            selectedWorkout.likes += 1
            DatabaseManager.shared.updateLikes(workout: selectedWorkout, likesCount: selectedWorkout.likes) {[weak self] workout in
                guard let self = self else {return}
                print ("likes increase by 1")
                self.listOfWorkouts[index] = workout
                self.filteredWorkouts = self.listOfWorkouts
                self.likesLabel.text = "\(workout.likes)"
                if !self.likedWorkouts.contains(selectedWorkout.id) {
                    self.likedWorkouts.append(selectedWorkout.id)
                    UserDefaults.standard.set(self.likedWorkouts, forKey: "likedWorkouts")
                }
            }
        } else {
            likeButton.setImage(UIImage(systemName: "heart", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .medium)), for: .normal)
            likeButton.tintColor = .white
            selectedWorkout.likes -= 1
            DatabaseManager.shared.updateLikes(workout: selectedWorkout, likesCount: selectedWorkout.likes) {[weak self] workout in
                guard let self = self else {return}
                print ("likes decrease by 1")
                self.listOfWorkouts[index] = workout
                self.filteredWorkouts = self.listOfWorkouts
                self.likesLabel.text = "\(workout.likes)"
                if let index = self.likedWorkouts.firstIndex(of: selectedWorkout.id) {
                    self.likedWorkouts.remove(at: index)
                    UserDefaults.standard.set(self.likedWorkouts, forKey: "likedWorkouts")
                }
            }
        }
        self.workoutsCollection.reloadData()
    }
    
    @objc private func toggleSearchBar() {
        searchBar.isHidden = !searchBar.isHidden
        
        if searchBar.isHidden {
            searchBarConstraint?.constant = -searchBar.frame.size.height
        } else {
            searchBarConstraint?.constant = 0
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .cancel)
        alert.addAction(cancelAction)
        alert.view.tintColor = .systemGreen
        self.present(alert, animated: true, completion: nil)
    }
}
// MARK: - Collection view data source and delegate methods
extension WorkoutsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        filteredWorkouts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: WorkoutsCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "workoutCell", for: indexPath) as! WorkoutsCollectionViewCell
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
        
        guard let safeIndexPath = selectedIndexPath else {print ("no index path")
            return
        }
        
        let selectedWorkout = filteredWorkouts[safeIndexPath.item]
        self.selectedWorkout = selectedWorkout
        selectedWorkoutView.randomizeBackgroungImages()
        updateUI(workout: selectedWorkout)
        
        if hasUserLikedWorkout(workout: selectedWorkout) == true {
            self.likeButton.isSelected = true
            likeButton.setImage(UIImage(systemName: "heart.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .medium)), for: .normal)
            likeButton.tintColor = .systemRed
        } else {
            self.likeButton.isSelected = false
            likeButton.setImage(UIImage(systemName: "heart", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .medium)), for: .normal)
            likeButton.tintColor = .white
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
         let scrollViewWidth = scrollView.frame.size.width
         let scrollContentSizeWidth = scrollView.contentSize.width
         let scrollOffset = scrollView.contentOffset.x
         if (scrollOffset + scrollViewWidth) >= (scrollContentSizeWidth - 50) && !isFetching && shouldLoadMorePosts {
             if !DatabaseManager.shared.allWorkoutsLoaded {
                 self.loadWorkoutsWithPagination(program: title!, pageSize: pageSize)
             } else {
                 shouldLoadMorePosts = false
                 print("All workouts have been loaded")
                 self.workoutsCollection.reloadData()
             }
         }
     }
}

extension WorkoutsViewController: UICollectionViewDelegateFlowLayout {
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

extension WorkoutsViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let searchQuery = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if searchQuery.count < 3 {
            filteredWorkouts = listOfWorkouts
            selectedWorkoutView.workoutDescriptionTextView.text = selectedWorkout?.description
            workoutsCollection.reloadData()
        } else {
            DatabaseManager.shared.searchWorkoutsByDescription(program: title!, searchText: searchQuery) { [weak self] workouts in
                guard let self = self else {return}
                self.filteredWorkouts = workouts.sorted(by: { $0.timestamp > $1.timestamp })
                if self.filteredWorkouts.isEmpty {
                    self.selectedWorkoutView.workoutDescriptionTextView.text = "Ooops! No workouts were found! Change your query and try again."
                } else {
                    self.selectedWorkoutView.workoutDescriptionTextView.text = "Select workout from search results."
                }
                self.workoutsCollection.reloadData()
            }
        }
    }
    private func setupSearchBarCancelButton() {
        if let cancelButton = searchBar.value(forKey: "cancelButton") as? UIButton {
            cancelButton.backgroundColor = .clear
            cancelButton.tintColor = .white
            cancelButton.setTitle(nil, for: .normal)
            cancelButton.setImage(UIImage(systemName: "clear", withConfiguration: UIImage.SymbolConfiguration(pointSize: 35, weight: .medium)), for: .normal)
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print ("executing method \(#function)")
        searchBar.text = nil
        filteredWorkouts = listOfWorkouts
        selectedWorkoutView.workoutDescriptionTextView.text = selectedWorkout?.description
        workoutsCollection.reloadData()
        let indexPath = IndexPath(row: 0, section: 0)
        self.workoutsCollection.selectItem(at: indexPath, animated: true, scrollPosition: .right)
        self.workoutsCollection.delegate?.collectionView?(self.workoutsCollection, didSelectItemAt: indexPath)
        searchBar.resignFirstResponder()
    }
}
