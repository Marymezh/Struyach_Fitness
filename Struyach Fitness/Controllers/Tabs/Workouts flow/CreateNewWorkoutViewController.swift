//
//  CreateNewWorkoutViewController.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 8/2/23.
//

import UIKit
import IQKeyboardManagerSwift

class CreateNewWorkoutViewController: UIViewController, UITextViewDelegate {
    
    var text: String = ""
    
    var onWorkoutSave: ((String) -> Void)?
    
    private let workoutDescriptionTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        textView.textColor = .black
        textView.tintColor = .black
        textView.backgroundColor = .white
        textView.layer.borderWidth = 0.5
        textView.layer.borderColor = UIColor.black.cgColor
        textView.layer.cornerRadius = 5
        textView.toAutoLayout()
        return textView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(named: "lightGreen")
    
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "SAVE", style: .done, target: self, action: #selector(addNewWorkout))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(cancel))
        
        setupTextView()
        setupSubviews()
    }
    
    @objc private func addNewWorkout() {
        if let text = workoutDescriptionTextView.text {
            self.onWorkoutSave?(text)
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc private func cancel() {
        navigationController?.popViewController(animated: true)
    }
    
    private func setupTextView() {
        #if Admin
        if text != "" {
            workoutDescriptionTextView.text = text
            workoutDescriptionTextView.isEditable = true
            let beginning = workoutDescriptionTextView.beginningOfDocument
            workoutDescriptionTextView.selectedTextRange = workoutDescriptionTextView.textRange(from: beginning, to: beginning)
            
        }
        #else
        if text != "" {
            workoutDescriptionTextView.text = text
            workoutDescriptionTextView.linkTextAttributes = [.foregroundColor: UIColor.systemBlue]
            workoutDescriptionTextView.isSelectable = true
            workoutDescriptionTextView.isEditable = false
            workoutDescriptionTextView.isUserInteractionEnabled = true
            workoutDescriptionTextView.dataDetectorTypes = .link

        }
        #endif
    }
    
    private func setupSubviews() {
        
        workoutDescriptionTextView.delegate = self
        workoutDescriptionTextView.becomeFirstResponder()
        
        view.addSubviews(workoutDescriptionTextView)

        var baseInset: CGFloat { return 15 }
        
        let constraints = [
            workoutDescriptionTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: baseInset),
            workoutDescriptionTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: baseInset),
            workoutDescriptionTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -baseInset),
            workoutDescriptionTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -baseInset)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}
