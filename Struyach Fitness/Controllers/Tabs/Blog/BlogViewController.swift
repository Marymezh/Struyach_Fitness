//
//  BlogTableViewController.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 5/4/23.
//

import UIKit
import FirebaseFirestore

class BlogViewController: UIViewController {
    
    private var blogPosts: [Post] = []
    private var selectedPost: Post?
    private var likedPosts = UserDefaults.standard.array(forKey: "likedPosts") as? [String] ?? []
    private let pageSize = 10
    private var lastDocumentSnapshot: DocumentSnapshot? = nil
    private var isFetching = false
    private var shouldLoadMorePosts = true
    private var tableView = UITableView(frame: .zero, style: .grouped)
    
    private lazy var plusButton: UIButton = {
       let button = UIButton()
        button.setImage(UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .medium)), for: .normal)
        button.backgroundColor = .systemGreen
        button.tintColor = .white
        button.addTarget(self, action: #selector(addNewPost), for: .touchUpInside)
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
        setupTableView()
#if Admin
        setupAdminFunctionality()
#endif
      //  loadBlogPostsWithPagination(pageSize: pageSize)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavAndTabBar()
        lastDocumentSnapshot = nil
        shouldLoadMorePosts = true
        DatabaseManager.shared.allPostsLoaded = false
        loadBlogPostsWithPagination(pageSize: pageSize)
    }
    
    private func setupNavAndTabBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        tabBarController?.tabBar.isHidden = false
        navigationController?.navigationBar.tintColor = .systemGreen
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.up", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .medium)), style: .done, target: self, action: #selector(scrollToTheTop))
    }
    
    private func setupTableView() {
        view.backgroundColor = .customDarkGray
        tableView.backgroundColor = .customDarkGray
        tableView.register(BlogTableViewCell.self, forCellReuseIdentifier: String(describing: BlogTableViewCell.self))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.toAutoLayout()
        view.addSubviews(tableView, plusButton)
        view.bringSubviewToFront(plusButton)
        let constraints = [
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            plusButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -25),
            plusButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            plusButton.widthAnchor.constraint(equalToConstant: 60),
            plusButton.heightAnchor.constraint(equalTo: plusButton.widthAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setupAdminFunctionality (){
        setupGestureRecognizer()
        plusButton.isHidden = false
    }
    
    @objc private func scrollToTheTop() {
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }
    
    @objc private func addNewPost() {
        print("Executing function: \(#function)")
        let newPostVC = CreateNewWorkoutViewController()
        newPostVC.title = "Add new post"
        tabBarController?.tabBar.isHidden = true
        navigationController?.pushViewController(newPostVC, animated: true)
        newPostVC.onWorkoutSave = {[weak self] text in
            let timestamp = Date().timeIntervalSince1970
            let date = Date(timeIntervalSince1970: timestamp)
            let formatter = DateFormatter()
            formatter.dateFormat = "EE d MMMM yyyy"
            let dateString = formatter.string(from: date)
            let postID = dateString.replacingOccurrences(of: " ", with: "_") + (UUID().uuidString)
            let newPost = Post(id: postID, description: text, date: dateString, timestamp: timestamp, likes: 0, comments: 0)
            DatabaseManager.shared.saveBlogPost(with: newPost) {[weak self] success in
                print("Executing function: \(#function)")
                guard let self = self else {return}
                if success {
                    self.lastDocumentSnapshot = nil
                    self.shouldLoadMorePosts = true
                    DatabaseManager.shared.allPostsLoaded = false
                    self.loadBlogPostsWithPagination(pageSize: self.pageSize)
                self.scrollToTheTop()
//                self.blogPosts.insert(newPost, at: 0)
//                self.tableView.reloadData()
                } else {
                    self.showAlert(title: "Warning", message: "Unable to add new post")
                }
            }
        }
    }
    
    private func loadBlogPostsWithPagination(pageSize: Int) {
        print ("executing function \(#function)")
        guard !isFetching else { return }
        isFetching = true
        DatabaseManager.shared.getBlogPostsWithPagination(pageSize: pageSize, startAfter: lastDocumentSnapshot) { [weak self] posts, lastDocumentSnapshot in
            guard let self = self else { return }
            if self.lastDocumentSnapshot == nil {
                self.blogPosts = posts
            } else {
                self.blogPosts.append(contentsOf: posts)
            }
            self.lastDocumentSnapshot = lastDocumentSnapshot
            self.tableView.reloadData()
            self.isFetching = false
        }
    }
    
    private func setupGestureRecognizer() {
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        tableView.addGestureRecognizer(longPressRecognizer)
    }
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        let touchPoint = gestureRecognizer.location(in: tableView)
        if let indexPath = tableView.indexPathForRow(at: touchPoint) {
            let alertController = UIAlertController(title: "EDIT OR DELETE", message: "Please choose edit action, delete action, of cancel", preferredStyle: .actionSheet)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] action in
                guard let self = self else { return }
                let post = self.blogPosts[indexPath.item]
                DatabaseManager.shared.deletePost(blogPost: post) { [weak self] success in
                    guard let self = self else { return }
                    if success {
                        self.blogPosts.remove(at: indexPath.row)
                        self.tableView.reloadData()
                        print ("number of posts left - \(self.blogPosts.count)")
                        self.showAlert(title: "Success", message: "Post is successfully deleted!")
                    } else {
                        self.showAlert(title: "Warning", message: "Unable to delete selected post")
                    }
                }
            }
            let editAction = UIAlertAction(title: "Edit", style: .default) { [weak self] action in
                guard let self = self else {return}
                let workoutVC = CreateNewWorkoutViewController()
                workoutVC.title = "Edit post"
                let selectedPost = self.blogPosts[indexPath.item]
                workoutVC.text = selectedPost.description
                self.navigationController?.pushViewController(workoutVC, animated: true)
                workoutVC.onWorkoutSave = {[weak self] text in
                    guard let self = self else {return}
                    DatabaseManager.shared.updatePost(blogPost: selectedPost, newDescription: text) { [weak self] post in
                        guard let self = self else {return}
                        guard let index = self.blogPosts.firstIndex(where: {$0 == selectedPost}) else {return}
                        self.blogPosts[index] = post
                        print(post.description)
                        self.tableView.reloadData()
                        self.showAlert(title: "Success", message: "Post is successfully updated!")
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

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .cancel)
        alert.addAction(cancelAction)
        alert.view.tintColor = .systemGreen
        self.present(alert, animated: true, completion: nil)
    }
    
    private func hasUserLikedPost(blogPost: Post) -> Bool {
        return self.likedPosts.contains(blogPost.id)
    }
}

    // MARK: - Table view data source and delegate methods
    
    extension BlogViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blogPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: BlogTableViewCell = tableView.dequeueReusableCell(withIdentifier: String(describing: BlogTableViewCell.self), for: indexPath) as! BlogTableViewCell
        var post = blogPosts[indexPath.row]
        
        cell.post = post
        
        cell.postDateLabel.text = post.date
        cell.postDescriptionTextView.text = post.description
        cell.likesLabel.text = "\(post.likes)"
        switch post.comments {
        case 0: cell.commentsLabel.text = "No comments posted yet"
        case 1: cell.commentsLabel.text = "\(post.comments) comment "
        default: cell.commentsLabel.text = "\(post.comments) comments"
        }
        if hasUserLikedPost(blogPost: post) == true {
            cell.likeButton.isSelected = true
            cell.likeButton.setImage(UIImage(systemName: "heart.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .medium)), for: .normal)
            cell.likeButton.tintColor = .systemRed
        } else {
            cell.likeButton.isSelected = false
            cell.likeButton.setImage(UIImage(systemName: "heart", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .medium)), for: .normal)
            cell.likeButton.tintColor = .white
        }
        
        cell.onLikeButtonPush = {
            cell.likeButton.isSelected = !cell.likeButton.isSelected
            
            if cell.likeButton.isSelected {
                cell.likeButton.setImage(UIImage(systemName: "heart.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .medium)), for: .normal)
                cell.likeButton.tintColor = .systemRed
                post.likes += 1
                DatabaseManager.shared.updateBlogLikes(blogPost: post, likesCount: post.likes) {[weak self] blogPost in
                    guard let self = self else {return}
                    print (blogPost.likes)
                    if let index = self.blogPosts.firstIndex(where: { $0.id == blogPost.id }) {
                            self.blogPosts[index] = blogPost
                    cell.likesLabel.text = "\(blogPost.likes)"
                    }
                    
                    if !self.likedPosts.contains(post.id) {
                        self.likedPosts.append(post.id)
                        UserDefaults.standard.set(self.likedPosts, forKey: "likedPosts")
                    }
                }
            } else {
                cell.likeButton.setImage(UIImage(systemName: "heart", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .medium)), for: .normal)
                cell.likeButton.tintColor = .white
                post.likes -= 1
                DatabaseManager.shared.updateBlogLikes(blogPost: post, likesCount: post.likes) {[weak self] blogPost in
                    guard let self = self else {return}
                    print (blogPost.likes)
                    if let index = self.blogPosts.firstIndex(where: { $0.id == blogPost.id }) {
                            self.blogPosts[index] = blogPost
                    cell.likesLabel.text = "\(blogPost.likes)"
                    }
                
                    if let index = self.likedPosts.firstIndex(of: post.id) {
                        self.likedPosts.remove(at: index)
                        UserDefaults.standard.set(self.likedPosts, forKey: "likedPosts")
                    }
                }
            }
        }
        
        cell.onCommentsPush = {
            let commentsVC = CommentsViewController(blogPost: post)
            commentsVC.title = "Comments"
            self.tabBarController?.tabBar.isHidden = true
            self.navigationController?.pushViewController(commentsVC, animated: true)
            
            commentsVC.onCommentsClose = {
                DatabaseManager.shared.getBlogCommentsCount(blogPost: post) { numberOfComments in
                    DatabaseManager.shared.updateBlogCommentsCount(blogPost: post, commentsCount: numberOfComments) { [weak self] blogPost in
                        guard let self = self else {return}
                        print ("number of blog post comments is \(blogPost.comments)")
                        if let index = self.blogPosts.firstIndex(where: { $0.id == blogPost.id }) {
                            self.blogPosts[index] = blogPost
                            switch blogPost.comments {
                            case 0: cell.commentsLabel.text = "No comments posted yet"
                            case 1: cell.commentsLabel.text = "\(blogPost.comments) comment "
                            default: cell.commentsLabel.text = "\(blogPost.comments) comments"
                            }
                        }
                    }
                }
            }
        }
        return cell
    }
        
   func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Check if table view is near bottom and not currently loading
        let scrollViewHeight = scrollView.frame.size.height
        let scrollContentSizeHeight = scrollView.contentSize.height
        let scrollOffset = scrollView.contentOffset.y
        if (scrollOffset + scrollViewHeight) >= (scrollContentSizeHeight - 50) && !isFetching && shouldLoadMorePosts {
            if !DatabaseManager.shared.allPostsLoaded {
                self.loadBlogPostsWithPagination(pageSize: pageSize)
            } else {
                shouldLoadMorePosts = false
                print("All posts have been loaded")
                self.tableView.tableFooterView = nil
                self.tableView.reloadData()
                scrollView.delegate = nil
            }
        }
    }
}


