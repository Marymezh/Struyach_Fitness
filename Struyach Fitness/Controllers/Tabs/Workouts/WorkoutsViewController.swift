//
//  SelectedProgramTableViewController.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 8/2/23.
//

import UIKit
import FirebaseFirestore

final class WorkoutsViewController: UIViewController {
    
    //MARK: - Properties
    
    private var listOfWorkouts: [Workout] = []
    private var filteredWorkouts: [Workout] = []
    private let currentUserEmail = UserDefaults.standard.string(forKey: "email")
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
    
    private var selectedWorkoutView = SelectedWorkoutView()
    private let likesAndCommentsView = LikesAndCommentsView()
    private let searchBarView = SearchBarView()
    private let plusButtonView = PlusButtonView()
    private lazy var programName: String = {
        switch title {
        case K.bodyweight.localized(): return "Bodyweight"
        case K.ecd.localized(): return "ECD Plan"
        case K.struyach.localized(): return "Struyach Plan"
        case K.bellyBurner.localized(): return "Belly Burner Plan"
        case K.pelvicPower.localized(): return "Pelvic Power Plan"
        default: return "Unknown Program"
        }
    }()
    
    private let selectedColor = UserDefaults.standard.colorForKey(key: "SelectedColor")
    private lazy var appColor = selectedColor ?? .systemGreen
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBarView.searchBar.delegate = self
        setupNavigationAndTabBar()
        setupCollectionView()
        setupSubviews()
#if Admin
        setupAdminFunctionality()
#else
        selectedWorkoutView.workoutDescriptionTextView.makeSecure()
        NotificationCenter.default.addObserver(self, selector: #selector(screenshotDetected), name: UIApplication.userDidTakeScreenshotNotification, object: nil)
#endif
        setupSearchBarCancelButton()
        self.loadWorkoutsWithPagination(program: programName, pageSize: self.pageSize)
        NotificationCenter.default.addObserver(self, selector: #selector(handleColorChange(_:)), name: Notification.Name("AppColorChanged"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("Executing function: \(#function)")
        navigationController?.navigationBar.prefersLargeTitles = true
        DatabaseManager.shared.allWorkoutsLoaded = false
        fetchLikedWorkouts()
        workoutsListener = DatabaseManager.shared.addWorkoutsListener(for: programName) { [weak self] updatedWorkouts in
            print("workout listener is on duty")
            guard let self = self else {return}
            self.listOfWorkouts = updatedWorkouts
            self.filteredWorkouts = self.listOfWorkouts
            if self.selectedWorkout != nil {
                for updatedWorkout in updatedWorkouts {
                    if updatedWorkout.id == self.selectedWorkout!.id {
                        self.selectedWorkout = updatedWorkout
                        DispatchQueue.main.async {
                            self.updateUI(workout: self.selectedWorkout!)
                            self.workoutsCollection.reloadData()
                            print ("selected workout updated by listener")
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
#if Client
        NotificationCenter.default.removeObserver(self)
#endif
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
           print ("workouts vc is deallocated")
       }
    
    @objc func handleColorChange(_ notification: Notification) {
        print ("changing workouts VC tint color")
        if let color = notification.object as? UIColor {
            self.appColor = color
            DispatchQueue.main.async {
                self.workoutsCollection.reloadData()
            }
        }
    }
    
    //MARK: - Method to prevent the content from copying, making screenshots or screen recording
    
    @objc private func screenshotDetected() {
        AlertManager.shared.showAlert(title: "Screenshot Detected".localized(), message: "It is not allowed to make screenshots of workouts due to content copyright. Please, respect our intellectual property.".localized(), cancelAction: "Ok")
    }
    
    //MARK: - Methods to setup Navigation Bar, TableView and subviews
    
    private func setupNavigationAndTabBar() {
        navigationController?.navigationBar.tintColor = appColor
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .medium)), style: .done, target: self, action: #selector(toggleSearchBar))
        tabBarController?.tabBar.isHidden = true
    }
    
    private func setupSubviews(){
        view.backgroundColor = .customDarkGray
        selectedWorkoutView.toAutoLayout()
        searchBarView.toAutoLayout()
        likesAndCommentsView.toAutoLayout()
        likesAndCommentsView.likeButton.addTarget(self, action: #selector(addLikeToWorkout), for: .touchUpInside)
        likesAndCommentsView.addCommentButton.addTarget(self, action: #selector(pushCommentsVC), for: .touchUpInside)
        plusButtonView.toAutoLayout()
        plusButtonView.plusButton.backgroundColor = appColor
        plusButtonView.plusButton.addTarget(self, action: #selector(addNewWorkout), for: .touchUpInside)
        
        view.addSubviews(searchBarView, workoutsCollection, selectedWorkoutView, likesAndCommentsView, plusButtonView)
        searchBarConstraint = searchBarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -44)
        
        let constraints = [
            searchBarConstraint!,
            searchBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            searchBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            searchBarView.heightAnchor.constraint(equalToConstant: 44),
        
            workoutsCollection.topAnchor.constraint(equalTo: searchBarView.bottomAnchor, constant: baseInset),
            workoutsCollection.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            workoutsCollection.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            workoutsCollection.heightAnchor.constraint(equalToConstant: 90),

            selectedWorkoutView.topAnchor.constraint(equalTo: workoutsCollection.bottomAnchor, constant: baseInset),
            selectedWorkoutView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            selectedWorkoutView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            selectedWorkoutView.bottomAnchor.constraint(equalTo: likesAndCommentsView.topAnchor, constant: -baseInset),
            
            likesAndCommentsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: baseInset),
            likesAndCommentsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -baseInset*2),
            likesAndCommentsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -baseInset),
            
            plusButtonView.bottomAnchor.constraint(equalTo: selectedWorkoutView.bottomAnchor, constant: -15),
            plusButtonView.trailingAnchor.constraint(equalTo: selectedWorkoutView.trailingAnchor, constant: -15),
            plusButtonView.widthAnchor.constraint(equalToConstant: 60),
            plusButtonView.heightAnchor.constraint(equalTo: plusButtonView.widthAnchor)
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
        plusButtonView.isHidden = false
    }
    
    private func clearUI() {
        likesAndCommentsView.likesLabel.text = "0"
        likesAndCommentsView.likeButton.isSelected = false
        likesAndCommentsView.likeButton.setImage(UIImage(systemName: "heart", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .medium)), for: .normal)
        likesAndCommentsView.likeButton.tintColor = .white
        likesAndCommentsView.commentsLabel.text = "No comments posted yet".localized()
    }
    
    private func updateUI(workout: Workout) {
        print("updating UI")
        DatabaseManager.shared.getCommentsCount(workout: workout) { numberOfComments in
            DatabaseManager.shared.updateWorkoutCommentsCount(workout: workout, commentsCount: numberOfComments) { [weak self] workout in
                guard let self = self else {return}
                print ("number of workout comments is \(workout.comments)")
                if let index = self.filteredWorkouts.firstIndex(where: { $0.id == workout.id }) {
                    self.filteredWorkouts[index] = workout
                    self.selectedWorkoutView.workoutDescriptionTextView.text = workout.description
                    self.likesAndCommentsView.likesLabel.text = "\(workout.likes)"
                    if self.likedWorkouts.contains(workout.id) {
                        self.likesAndCommentsView.likeButton.setImage(UIImage(systemName: "heart.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .medium)), for: .normal)
                        likesAndCommentsView.likeButton.tintColor = .systemRed
                    } else {
                        self.likesAndCommentsView.likeButton.setImage(UIImage(systemName: "heart", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .medium)), for: .normal)
                        likesAndCommentsView.likeButton.tintColor = .white
                    }
                    switch workout.comments {
                    case 0: self.likesAndCommentsView.commentsLabel.text = "No comments posted yet".localized()
                    case 1: self.likesAndCommentsView.commentsLabel.text = "1 comment".localized()
                    default: self.likesAndCommentsView.commentsLabel.text = String(format: "%d comments".localized(), workout.comments)
                    }
                }
            }
        }
    }
    
    // MARK: - Adding new workout and loading list of workouts
    // only Admin user can add new workout
    @objc private func addNewWorkout() {
        print("Executing function: \(#function)")
        let newWorkoutVC = TextViewController()
        newWorkoutVC.title = "Add new workout".localized()
        navigationController?.pushViewController(newWorkoutVC, animated: true)
        newWorkoutVC.onWorkoutSave = {[weak self] text, selectedDate in
            guard let self = self else {return}
            guard let selectedDate = selectedDate else {
                return
            }
            
            let topic = self.programName.replacingOccurrences(of: " ", with: "_")
            let message = UserPush(
                title: "New workout posted!".localized(),
                body: String(format: "Check the %@ to see a new workout.".localized(), self.programName.localized()), type: "newWorkout",
                destination: self.programName, collectionId: nil)
            NotificationsManager.shared.sendPush(toTopic: topic, push: message) { success in
                if success {
                    print ("notification for \(self.programName) is sent")
                } else {
                    print ("failed to send notification")
                }
            }

            let timestamp = selectedDate
            let date = Date(timeIntervalSince1970: timestamp)
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
            let dateString = formatter.string(from: date)
            let workoutID = "\(self.programName)_\(dateString)"
            let newWorkout = Workout(id: workoutID, programID: self.programName, description: text, timestamp: selectedDate, likes: 0)
            DatabaseManager.shared.postWorkout(with: newWorkout) {[weak self] success in
                print("Executing function: \(#function)")
                guard let self = self else {return}
                if success {
                    self.workoutsCollection.reloadData()
                    let indexPath = IndexPath(row: 0, section: 0)
                    self.workoutsCollection.selectItem(at: indexPath, animated: true, scrollPosition: .right)
                    self.workoutsCollection.delegate?.collectionView?(self.workoutsCollection, didSelectItemAt: indexPath)
                    print ("success! should reload collection view and select first item")
                } else {
                    AlertManager.shared.showAlert(title: "Warning".localized(), message: "Unable to post new workout".localized(), cancelAction: "Ok")
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
                    self.selectedWorkoutView.workoutDescriptionTextView.text = "No workouts found for this program".localized()
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
        longPress.minimumPressDuration = 0.5
        workoutsCollection.addGestureRecognizer(longPress)
    }
    
    @objc func handleLongPress(sender: UILongPressGestureRecognizer) {
        guard sender.state == .began else {
             return
         }
        print("Executing function: \(#function)")
        let location = sender.location(in: workoutsCollection)
        if let indexPath = workoutsCollection.indexPathForItem(at: location) {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let deleteAction = UIAlertAction(title: "Delete".localized(), style: .destructive) { [weak self] action in
                guard let self = self else {return}
                let workout = self.listOfWorkouts[indexPath.item]
                DatabaseManager.shared.deleteWorkout(workout: workout) {[weak self] success in
                    guard let self = self else { return }
                    if success {
                        self.clearUI()
                        print ("number of workouts left - \(self.listOfWorkouts.count)")
                        switch self.listOfWorkouts.isEmpty {
                        case true:
                            self.selectedWorkoutView.workoutDescriptionTextView.text = "No workouts found for this program".localized()
                        case false:
                            self.selectedWorkoutView.workoutDescriptionTextView.text = "Workout successfully deleted".localized()
                        }
                    } else {
                        AlertManager.shared.showAlert(title: "Warning".localized(), message: "Unable to delete this workout".localized(), cancelAction: "Ok")
                    }
                }
            }
            
            let editAction = UIAlertAction(title: "Edit".localized(), style: .default) { [weak self] action in
                guard let self = self else {return}
                let workoutVC = TextViewController()
                workoutVC.title = "Edit workout".localized()
                let selectedWorkout = self.listOfWorkouts[indexPath.item]
                workoutVC.text = selectedWorkout.description
                self.navigationController?.pushViewController(workoutVC, animated: true)
                workoutVC.onWorkoutSave = {text, _ in
                    DatabaseManager.shared.updateWorkout(workout: selectedWorkout, newDescription: text) { workout in
                        AlertManager.shared.showAlert(title: "Success".localized(), message: "Workout is successfully updated!".localized(), cancelAction: "Ok")
                    }
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel)
            alertController.addAction(editAction)
            alertController.addAction(deleteAction)
            alertController.addAction(cancelAction)
            alertController.view.tintColor = ColorManager.shared.appColor
            present(alertController, animated: true)
        }
    }
    
    @objc private func pushCommentsVC() {
        guard let selectedWorkout = selectedWorkout else { print("workout is not selected")
            return }
        let commentsVC = CommentsViewController(workout: selectedWorkout)
        commentsVC.title = "Comments".localized()
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "Back".localized(), style: .plain, target: nil, action: nil)
        navigationController?.pushViewController(commentsVC, animated: true)
        
        commentsVC.onCommentPosted = {[weak self] in
            guard let self = self else {return}
            self.updateUI(workout: selectedWorkout)
        }
    }
    
    //MARK: - Methods to handle likes and toggle search bar
    
    private func fetchLikedWorkouts() {
        print ("fetching liked workouts")
        guard let email = currentUserEmail else { return }
        
        DatabaseManager.shared.getUser(email: email) { [weak self] user in
            guard let user = user,
                  let self = self,
                  let ref = user.likedWorkouts else { return }
            
            StorageManager.shared.downloadUrl(path: ref) { url in
                guard let url = url else { return }
                
                let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
                    if let error = error {
                        print ("Unable to fetch liked workouts")
                        print (error.localizedDescription)
                        return
                    }
                    
                    guard let data = data else {
                        print("Data is nil.")
                        return
                    }
                    
                    do {
                        let likedWorkouts = try JSONDecoder().decode([String].self, from: data)
                        DispatchQueue.main.async {
                            self?.likedWorkouts = likedWorkouts
                            print (likedWorkouts.count)
                            UserDefaults.standard.set(likedWorkouts, forKey: "likedWorkouts")
                            self?.workoutsCollection.reloadData()
                        }
                    } catch {
                        print ("error decoding list of workouts liked by current user")
                    }
                }
                task.resume()
            }
        }
    }
    
    private func uploadLikedWorkouts() {
        // upload saved likedPosts array to Firebase Storage
        guard let email = currentUserEmail else {return}
        StorageManager.shared.uploadLikedWorkouts(email: email, likedWorkouts: likedWorkouts) { success in
            if success {
                DatabaseManager.shared.updateLikedWorkouts(email: email) { success in
                    guard success else {return}
                    print ("liked workouts are updated")
                }
            }
        }
    }
    
    @objc private func addLikeToWorkout() {
        guard var selectedWorkout = selectedWorkout else {
            print ("workout is not selected")
            return}
        if !likedWorkouts.contains(selectedWorkout.id) {
            likesAndCommentsView.likeButton.setImage(UIImage(systemName: "heart.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .medium)), for: .normal)
            likesAndCommentsView.likeButton.tintColor = .systemRed
            selectedWorkout.likes += 1
            DatabaseManager.shared.updateLikes(workout: selectedWorkout, likesCount: selectedWorkout.likes) {[weak self] success in
                guard let self = self else {return}
                print ("likes increase by 1")
                    self.likedWorkouts.append(selectedWorkout.id)
                    self.uploadLikedWorkouts()
            }
        } else {
            likesAndCommentsView.likeButton.setImage(UIImage(systemName: "heart", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .medium)), for: .normal)
            likesAndCommentsView.likeButton.tintColor = .white
            selectedWorkout.likes -= 1
            DatabaseManager.shared.updateLikes(workout: selectedWorkout, likesCount: selectedWorkout.likes) {[weak self] success in
                guard let self = self else {return}
                print ("likes decrease by 1")
                if let index = self.likedWorkouts.firstIndex(of: selectedWorkout.id) {
                    self.likedWorkouts.remove(at: index)
                    self.uploadLikedWorkouts()
                }
            }
        }
    }
    
    @objc private func toggleSearchBar() {
        searchBarView.searchBar.isHidden = !searchBarView.searchBar.isHidden
        
        if searchBarView.searchBar.isHidden {
            searchBarConstraint?.constant = -searchBarView.searchBar.frame.size.height
        } else {
            searchBarConstraint?.constant = 0
        }
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
        
        if workout.programID == "Belly Burner Plan" || workout.programID == "Pelvic Power Plan" {
            cell.configure(with: indexPath)
        }
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
                 self.loadWorkoutsWithPagination(program: self.programName, pageSize: pageSize)
             } else {
                 shouldLoadMorePosts = false
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
            cell.workoutDateLabel.backgroundColor = appColor
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
            DatabaseManager.shared.searchWorkoutsByDescription(program: self.programName, searchText: searchQuery) { [weak self] workouts in
                guard let self = self else {return}
                self.filteredWorkouts = workouts.sorted(by: { $0.timestamp > $1.timestamp })
                if self.filteredWorkouts.isEmpty {
                    self.selectedWorkoutView.workoutDescriptionTextView.text = "Ooops! No workouts were found! Change your query and try again.".localized()
                } else {
                    self.selectedWorkoutView.workoutDescriptionTextView.text = "Select workout from search results".localized()
                }
                self.workoutsCollection.reloadData()
            }
        }
    }
    
    private func setupSearchBarCancelButton() {
        if let cancelButton = searchBarView.searchBar.value(forKey: "cancelButton") as? UIButton {
            cancelButton.backgroundColor = .clear
            cancelButton.tintColor = .white
            cancelButton.setTitle(nil, for: .normal)
            cancelButton.setImage(UIImage(systemName: "clear", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .regular)), for: .normal)
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print ("executing method \(#function)")
        searchBar.text = nil
        if !listOfWorkouts.isEmpty {
            filteredWorkouts = listOfWorkouts
            selectedWorkoutView.workoutDescriptionTextView.text = selectedWorkout?.description
            workoutsCollection.reloadData()
            let indexPath = IndexPath(row: 0, section: 0)
            self.workoutsCollection.selectItem(at: indexPath, animated: true, scrollPosition: .right)
            self.workoutsCollection.delegate?.collectionView?(self.workoutsCollection, didSelectItemAt: indexPath)
            searchBar.resignFirstResponder()
        }
    }
}

