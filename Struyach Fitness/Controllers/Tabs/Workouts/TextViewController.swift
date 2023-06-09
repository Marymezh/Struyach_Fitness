//
//  TextViewController.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 8/2/23.
//

import UIKit
import IQKeyboardManagerSwift

final class TextViewController: UIViewController, UITextViewDelegate {
    
    //MARK: - Properties
    
    var text: String = ""
    var onWorkoutSave: ((String) -> Void)?
    
    let workoutDescriptionTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        textView.textColor = .black
        textView.tintColor = .black
        textView.isScrollEnabled = true 
        textView.backgroundColor = .white
        textView.layer.cornerRadius = 5
        textView.toAutoLayout()
        return textView
    }()

    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .customDarkGray
        navigationController?.navigationBar.prefersLargeTitles = false
        tabBarController?.tabBar.isHidden = true 
        configureButtons()
        setupTextView()
        setupSubviews()
    }
    
    deinit {
           print ("text view controller is deallocated")
       }
    
    
    //MARK: Setup methods
    
    private func configureButtons() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "SAVE".localized(), style: .done, target: self, action: #selector(addNewWorkout))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel".localized(), style: .done, target: self, action: #selector(cancel))
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
        let textViewHeight = self.view.frame.height / 2.4
        
        let constraints = [
            workoutDescriptionTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: baseInset*2),
            workoutDescriptionTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: baseInset),
            workoutDescriptionTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -baseInset),
            workoutDescriptionTextView.heightAnchor.constraint(equalToConstant: textViewHeight),
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    //MARK: - Buttons action methods
    
    @objc private func addNewWorkout() {
        if let text = workoutDescriptionTextView.text,
              text != "" {
            self.onWorkoutSave?(text)
            self.navigationController?.popViewController(animated: true)
        } else {
            AlertManager.shared.showAlert(title: "Warning".localized(), message: "This textfield can not be blank!".localized(), cancelAction: "Cancel".localized())
        }
    }
    
    @objc private func cancel() {
        navigationController?.popViewController(animated: true)
    }
}
