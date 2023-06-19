//
//  BlogTableViewController.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 5/4/23.
//

import UIKit
import FirebaseFirestore

final class BlogViewController: UIViewController {
    
    //MARK: - Properties
    
    private var blogPosts: [Post] = []
    private var selectedPost: Post?
    private let currentUserEmail = UserDefaults.standard.string(forKey: "email")
    private var likedPosts = UserDefaults.standard.array(forKey: "likedPosts") as? [String] ?? []
    private let pageSize = 10
    private var lastDocumentSnapshot: DocumentSnapshot? = nil
    private var isFetching = false
    private var shouldLoadMorePosts = true
    private var postUpdatesListener: ListenerRegistration?
    private var tableView = UITableView(frame: .zero, style: .grouped)
    
    private let plusButtonView = PlusButtonView()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
#if Admin
        setupAdminFunctionality()
#endif
        loadBlogPostsWithPagination(pageSize: pageSize)
        fetchLikedPosts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavAndTabBar()
        DatabaseManager.shared.allPostsLoaded = false
        tableView.reloadData()
        postUpdatesListener = DatabaseManager.shared.addBlogPostsListener { [weak self] updatedPosts in
            guard let self = self else {return}
            self.blogPosts = updatedPosts
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        postUpdatesListener?.remove()
        print ("blog vc will disappear, listener is removed")
    }
    
    deinit {
           print ("blog vc is deallocated")
       }
    
    
    //MARK: - Setup methods
    
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
        tableView.separatorStyle = .none
        plusButtonView.toAutoLayout()
        plusButtonView.plusButton.addTarget(self, action: #selector(addNewPost), for: .touchUpInside)
        view.addSubviews(tableView, plusButtonView)
        let constraints = [
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            plusButtonView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5),
            plusButtonView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            plusButtonView.widthAnchor.constraint(equalToConstant: 60),
            plusButtonView.heightAnchor.constraint(equalTo: plusButtonView.widthAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setupAdminFunctionality (){
        setupGestureRecognizer()
        plusButtonView.isHidden = false
    }
    
    private func setupGestureRecognizer() {
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        tableView.addGestureRecognizer(longPressRecognizer)
    }
    
    //MARK: - Buttons methods

    @objc private func scrollToTheTop() {
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }
    
    @objc private func addNewPost() {
        print("Executing function: \(#function)")
        let newPostVC = TextViewController()
        newPostVC.title = "Add new post".localized()
        tabBarController?.tabBar.isHidden = true
        navigationController?.pushViewController(newPostVC, animated: true)
        newPostVC.onWorkoutSave = {[weak self] text, selectedDate in
            guard let selectedDate = selectedDate else {return}
            let timestamp = Date().timeIntervalSince1970
            let date = Date(timeIntervalSince1970: timestamp)
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy"
            let dateString = formatter.string(from: date)
            let postID = dateString + (UUID().uuidString)
            let newPost = Post(id: postID, description: text, timestamp: selectedDate, likes: 0, comments: 0)
            DatabaseManager.shared.saveBlogPost(with: newPost) {[weak self] success in
                print("Executing function: \(#function)")
                guard let self = self else {return}
                if success {
                    if self.blogPosts.count > 1 {
                        self.scrollToTheTop()
                    }
                } else {
                    AlertManager.shared.showAlert(title: "Warning".localized(), message: "Unable to add new post".localized(), cancelAction: "Ok")
                }
            }
        }
    }
    
    //MARK: - Methods to fetch, edit and delete blog posts
    
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
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        let touchPoint = gestureRecognizer.location(in: tableView)
        if let indexPath = tableView.indexPathForRow(at: touchPoint) {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let deleteAction = UIAlertAction(title: "Delete".localized(), style: .destructive) { [weak self] action in
                guard let self = self else { return }
                let post = self.blogPosts[indexPath.item]
                DatabaseManager.shared.deletePost(blogPost: post) { [weak self] success in
                    guard let self = self else { return }
                    if success {
                        print ("number of posts left - \(self.blogPosts.count)")
                        switch self.blogPosts.isEmpty {
                        case true:
                            AlertManager.shared.showAlert(title: "Success".localized(), message: "Post is successfully deleted! No more posts left in the Blog".localized(), cancelAction: "Ok")
                        case false:
                            AlertManager.shared.showAlert(title: "Success".localized(), message: "Post is successfully deleted!".localized(), cancelAction: "Ok")
                        }
                    } else {
                        AlertManager.shared.showAlert(title: "Warning".localized(), message: "Unable to delete selected post".localized(), cancelAction: "Ok")
                    }
                }
            }
            let editAction = UIAlertAction(title: "Edit".localized(), style: .default) { [weak self] action in
                guard let self = self else {return}
                let workoutVC = TextViewController()
                workoutVC.title = "Edit post".localized()
                let selectedPost = self.blogPosts[indexPath.item]
                workoutVC.text = selectedPost.description
                self.navigationController?.pushViewController(workoutVC, animated: true)
                workoutVC.onWorkoutSave = {text, _ in
                    DatabaseManager.shared.updatePost(blogPost: selectedPost, newDescription: text) { post in
                        AlertManager.shared.showAlert(title: "Success".localized(), message: "Post is successfully updated!".localized(), cancelAction: "Ok")
                    }
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel)
            alertController.addAction(editAction)
            alertController.addAction(deleteAction)
            alertController.addAction(cancelAction)
            alertController.view.tintColor = .darkGray
            present(alertController, animated: true)
        }
    }
    
    //functions to upload and fetch liked posts
    private func fetchLikedPosts() {
        guard let email = currentUserEmail else {return}
        DatabaseManager.shared.getUser(email: email) { [weak self] user in
            guard let user = user,
                  let self = self,
                  let ref = user.likedPosts else {return}
            StorageManager.shared.downloadUrl(path: ref) { url in
                guard let url = url else {return}
                
                let task = URLSession.shared.dataTask(with: url) { data, _, _ in
                    guard let data = data else {return}
                    self.likedPosts = try! JSONDecoder().decode([String].self, from: data)
                    UserDefaults.standard.set(self.likedPosts, forKey: "likedPosts")
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
                task.resume()
            }
        }
    }
    
    private func uploadLikedPosts() {
        // upload saved likedPosts array to Firebase Storage
        guard let email = currentUserEmail else {return}
        StorageManager.shared.uploadLikedPosts(email: email, likedPosts: likedPosts) { success in
            if success {
                DatabaseManager.shared.updateLikedPosts(email: email) { [weak self] success in
                    guard success else {return}
                    guard let self = self else {return}
                    print ("liked posts are updated")
                    self.fetchLikedPosts()
                }
            }
        }
    }
}

    // MARK: - Table view dataSource and delegate methods
    
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
        let currentLanguage = LanguageManager.shared.currentLanguage
        let date = Date(timeIntervalSince1970: post.timestamp)
        let formatter = DateFormatter()
        if currentLanguage.rawValue == "ru" { // Russian
            formatter.locale = Locale(identifier: "ru_RU")
            formatter.dateFormat = "EEE, d MMMM yyyy"

        } else { // English (default)
            formatter.locale = Locale(identifier: "en_US")
            formatter.dateFormat = "EEE, MMMM d, yyyy"
        }
        let dateString = formatter.string(from: date)
        cell.postDateLabel.text = dateString
        cell.likesAndCommentsView.likesLabel.text = "\(post.likes)"
        cell.postDescriptionTextView.text = post.description
        DatabaseManager.shared.getBlogCommentsCount(blogPost: post) { numberOfComments in
            DatabaseManager.shared.updateBlogCommentsCount(blogPost: post, commentsCount: numberOfComments) { [weak cell] blogPost in
                guard let cell = cell else {return}
                print ("number of blog post comments is \(blogPost.comments)")
                    switch blogPost.comments {
                    case 0: cell.likesAndCommentsView.commentsLabel.text = "No comments posted yet".localized()
                    case 1: cell.likesAndCommentsView.commentsLabel.text = "1 comment".localized()
                    default: cell.likesAndCommentsView.commentsLabel.text = String(format: "%d comments".localized(), post.comments)
                }
            }
        }
        
        if likedPosts.contains(post.id) {
            cell.likesAndCommentsView.likeButton.isSelected = true
            cell.likesAndCommentsView.likeButton.setImage(UIImage(systemName: "heart.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .medium)), for: .normal)
            cell.likesAndCommentsView.likeButton.tintColor = .systemRed
        } else {
            cell.likesAndCommentsView.likeButton.isSelected = false
            cell.likesAndCommentsView.likeButton.setImage(UIImage(systemName: "heart", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .medium)), for: .normal)
            cell.likesAndCommentsView.likeButton.tintColor = .white
        }
        
        cell.onLikeButtonPush = { [weak self, weak cell] in
            guard let self = self, let cell = cell else { return }
            cell.likesAndCommentsView.likeButton.isSelected = !cell.likesAndCommentsView.likeButton.isSelected

            if cell.likesAndCommentsView.likeButton.isSelected {
                cell.likesAndCommentsView.likeButton.setImage(UIImage(systemName: "heart.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .medium)), for: .normal)
                cell.likesAndCommentsView.likeButton.tintColor = .systemRed
                post.likes += 1
                DatabaseManager.shared.updateBlogLikes(blogPost: post, likesCount: post.likes) {[weak self] blogPost in
                    guard let self = self else {return}
                    print (blogPost.likes)
                    if let index = self.blogPosts.firstIndex(where: { $0.id == blogPost.id }) {
                            self.blogPosts[index] = blogPost
                        cell.likesAndCommentsView.likesLabel.text = "\(blogPost.likes)"
                    }

                    if !self.likedPosts.contains(post.id) {
                        self.likedPosts.append(post.id)
                        self.uploadLikedPosts()
                
                    }
                }
            } else {
                cell.likesAndCommentsView.likeButton.setImage(UIImage(systemName: "heart", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .medium)), for: .normal)
                cell.likesAndCommentsView.likeButton.tintColor = .white
                post.likes -= 1
                DatabaseManager.shared.updateBlogLikes(blogPost: post, likesCount: post.likes) {[weak self] blogPost in
                    guard let self = self else {return}
                    print (blogPost.likes)
                    if let index = self.blogPosts.firstIndex(where: { $0.id == blogPost.id }) {
                            self.blogPosts[index] = blogPost
                        cell.likesAndCommentsView.likesLabel.text = "\(blogPost.likes)"
                    }

                    if let index = self.likedPosts.firstIndex(of: post.id) {
                        self.likedPosts.remove(at: index)
                        self.uploadLikedPosts()
                    
                    }
                }
            }
        }

        cell.onCommentsPush = { [weak self, weak cell] in
            guard let self = self, let cell = cell else { return }
            let commentsVC = CommentsViewController(blogPost: post)
            commentsVC.title = "Comments".localized()
            self.tabBarController?.tabBar.isHidden = true
            self.navigationController?.pushViewController(commentsVC, animated: true)

            commentsVC.onCommentPosted = {
                DatabaseManager.shared.getBlogCommentsCount(blogPost: post) { numberOfComments in
                    DatabaseManager.shared.updateBlogCommentsCount(blogPost: post, commentsCount: numberOfComments) { [weak self, weak cell] blogPost in
                        guard let self = self, let cell = cell else {return}
                        print ("number of blog post comments is \(blogPost.comments)")
                        if let index = self.blogPosts.firstIndex(where: { $0.id == blogPost.id }) {
                            self.blogPosts[index] = blogPost
                            switch blogPost.comments {
                            case 0: cell.likesAndCommentsView.commentsLabel.text = "No comments posted yet".localized()
                            case 1: cell.likesAndCommentsView.commentsLabel.text = "1 comment".localized()
                            default: cell.likesAndCommentsView.commentsLabel.text = String(format: "%d comments".localized(), post.comments)
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
                self.tableView.tableFooterView = nil
                self.tableView.reloadData()
                scrollView.delegate = nil
            }
        }
    }
}


