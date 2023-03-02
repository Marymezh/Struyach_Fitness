//
//  SelectedWorkoutHeaderView.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 8/2/23.
//

import UIKit

class SelectedWorkoutHeaderView: UIView, UITextViewDelegate {
    
    var onSendCommentPush: ((String, Data, String, String) -> Void)?
    
    var onTextChanged: (() -> Void)?
    
    private var baseInset: CGFloat { return 15 }
    private var innerInset: CGFloat { return 10 }
    
    private let workoutView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.cornerRadius = 5
        view.alpha = 0.8
        view.toAutoLayout()
        return view
    }()
    
    let workoutDescriptionTextView: UITextView = {
        let textView = UITextView()
        textView.sizeToFit()
        textView.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        textView.textAlignment = .left
        textView.isEditable = false
        textView.linkTextAttributes = [.foregroundColor: UIColor.systemBlue]
        textView.isSelectable = true
//        textView.isScrollEnabled = false
//        textView.sizeToFit()
        textView.isUserInteractionEnabled = true
        textView.dataDetectorTypes = .link
        textView.layer.borderColor = UIColor.white.cgColor
        textView.toAutoLayout()
        return textView
    }()
    
    private lazy var fullScreenButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "arrow.up.left.and.arrow.down.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .medium)), for: .normal)
        button.tintColor = .systemGray
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 0.5
        button.addTarget(self, action: #selector(fullScreenPressed), for: .touchUpInside)
        button.toAutoLayout()
        return button
    }()
    //TODO: - may be delete this button
    
    @objc func fullScreenPressed () {
        let text = workoutDescriptionTextView.text
        let fullWorkoutDescriptionVC = CreateNewWorkoutViewController()
        fullWorkoutDescriptionVC.workoutDescriptionTextView.isEditable = false
        fullWorkoutDescriptionVC.workoutDescriptionTextView.isUserInteractionEnabled = false 
        fullWorkoutDescriptionVC.text = text ?? "workout description"
        self.window?.rootViewController?.present(fullWorkoutDescriptionVC, animated: true)
    }
    
    let commentTextView: UITextView = {
       let textView = UITextView()
        textView.toAutoLayout()
        textView.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        textView.textColor = .black
        textView.tintColor = .black
        textView.sizeToFit()
        textView.isScrollEnabled = false
        textView.backgroundColor = .white
        textView.layer.borderWidth = 0.5
        textView.layer.borderColor = UIColor.black.cgColor
        textView.layer.cornerRadius = 5
        return textView
    }()
    
    private lazy var addCommentButton: UIButton = {
        let button = UIButton()
        button.toAutoLayout()
        button.tintColor = .white
        button.setImage(UIImage(systemName: "paperplane.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .medium)), for: .normal)
        button.addTarget(self, action: #selector(commentSent), for: .touchUpInside)
        return button
    }()
    
    
    @objc func commentSent() {
        if let text = commentTextView.text,
        text != "" {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM, yyyy HH:mm"
        let date = formatter.string(from: Date())
        guard let userName = UserDefaults.standard.object(forKey: "userName") as? String else {return}
        guard let userImage = UserDefaults.standard.data(forKey: "userImage") else {return}
        self.onSendCommentPush?(userName, userImage, text, date)
        } else {
            showAlert(error: "Please enter your comment first!")
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        if let backgroundImage = UIImage(named: "general") {
        backgroundColor = UIColor(patternImage: backgroundImage)
        }
        commentTextView.delegate = self
        
        self.addSubviews (workoutView, fullScreenButton, commentTextView, addCommentButton)
        workoutView.addSubview(workoutDescriptionTextView)
        
        let textViewHeight: CGFloat = 320
        
        let constraints = [
            
            workoutView.topAnchor.constraint(equalTo: self.topAnchor, constant: baseInset),
            workoutView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: baseInset),
            workoutView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -baseInset),
            workoutView.heightAnchor.constraint(equalToConstant: textViewHeight),

            workoutDescriptionTextView.topAnchor.constraint(equalTo: workoutView.topAnchor, constant: innerInset),
            workoutDescriptionTextView.leadingAnchor.constraint(equalTo: workoutView.leadingAnchor, constant: innerInset),
            workoutDescriptionTextView.trailingAnchor.constraint(equalTo: workoutView.trailingAnchor, constant: -innerInset),
            workoutDescriptionTextView.bottomAnchor.constraint(equalTo: workoutView.bottomAnchor, constant: -innerInset),
            
            fullScreenButton.trailingAnchor.constraint(equalTo: workoutView.trailingAnchor, constant: -innerInset),
            fullScreenButton.topAnchor.constraint(equalTo: workoutView.topAnchor, constant: innerInset),
            fullScreenButton.heightAnchor.constraint(equalToConstant: 35),
            fullScreenButton.widthAnchor.constraint(equalTo: fullScreenButton.heightAnchor),
            
            commentTextView.topAnchor.constraint(equalTo: workoutView.bottomAnchor, constant: baseInset),
            commentTextView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: baseInset),
            commentTextView.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -70),
            commentTextView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -baseInset),
            
            addCommentButton.topAnchor.constraint(equalTo: workoutView.bottomAnchor, constant: baseInset),
            addCommentButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -baseInset),
            addCommentButton.widthAnchor.constraint(equalToConstant: 35),
            addCommentButton.heightAnchor.constraint(equalToConstant: 35),
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        onTextChanged?()
    }
    
    private func showAlert (error: String) {
        let alert = UIAlertController(title: "Warning", message: error, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)
        
        self.window?.rootViewController?.present(alert, animated: true)
    }

}
