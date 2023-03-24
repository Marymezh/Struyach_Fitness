//
//  CreateNewWorkoutViewController.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 8/2/23.
//

import UIKit
import IQKeyboardManagerSwift

class CreateNewWorkoutViewController: UIViewController, UITextViewDelegate {
    
    //MARK: - Properties
    
    var text: String = ""
    var onWorkoutSave: ((String) -> Void)?
    let workoutDescriptionTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        textView.textColor = .black
        textView.tintColor = .black
        textView.isScrollEnabled = true 
        textView.backgroundColor = .white
        textView.layer.cornerRadius = 5
        textView.toAutoLayout()
        return textView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .customDarkGray
        navigationController?.navigationBar.prefersLargeTitles = false
        configureButtons()
        setupTextView()
        setupSubviews()
    }
    
    private func configureButtons() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "SAVE", style: .done, target: self, action: #selector(addNewWorkout))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(cancel))
    }
    
    @objc private func addNewWorkout() {
        if let text = workoutDescriptionTextView.text,
              text != "" {
            self.onWorkoutSave?(text)
            navigationController?.popViewController(animated: true)
        } else {
            self.showAlert(error: "Enter workout description!")
        }
    }
    
    @objc private func cancel() {
        navigationController?.popViewController(animated: true)
    }
    
    private func setupTextView() {
        if text != "" {
            workoutDescriptionTextView.text = text
            workoutDescriptionTextView.linkTextAttributes = [.foregroundColor: UIColor.systemBlue]
            workoutDescriptionTextView.isSelectable = true
            workoutDescriptionTextView.isEditable = true
            workoutDescriptionTextView.isUserInteractionEnabled = true
            workoutDescriptionTextView.dataDetectorTypes = .link
        }
    }
    
    private func setupSubviews() {
        
        workoutDescriptionTextView.delegate = self
        workoutDescriptionTextView.becomeFirstResponder()
        
        view.addSubviews(workoutDescriptionTextView)

        var baseInset: CGFloat { return 15 }
        let textViewHeight = self.view.frame.height / 2.2
        
        let constraints = [
            workoutDescriptionTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: baseInset*2),
            workoutDescriptionTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: baseInset),
            workoutDescriptionTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -baseInset),
            workoutDescriptionTextView.heightAnchor.constraint(equalToConstant: textViewHeight),
//            workoutDescriptionTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -baseInset*2)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    private func showAlert (error: String) {
        let alert = UIAlertController(title: "Warning", message: error, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
}
