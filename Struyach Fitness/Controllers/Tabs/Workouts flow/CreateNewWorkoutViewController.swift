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
    
    private lazy var addButton: UIButton = {
        let button = UIButton()
        button.setTitle("Add", for: .normal)
        button.backgroundColor = UIColor(named: "darkGreen")
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.black.cgColor
        button.addTarget(self, action: #selector(addNewWorkout), for: .touchUpInside)
        button.toAutoLayout()
        return button
    }()
    
    @objc func addNewWorkout() {
        if let text = workoutDescriptionTextView.text {
            self.onWorkoutSave?(text)
            navigationController?.popViewController(animated: true)
        }
    }
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Cancel", for: .normal)
        button.backgroundColor = UIColor(named: "darkGreen")
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.black.cgColor
        button.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        button.toAutoLayout()
        return button
    }()
    
    @objc func cancel() {
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(named: "lightGreen")
        #if Admin
        if text != "" {
            workoutDescriptionTextView.text = text
            workoutDescriptionTextView.isEditable = true
            let beginning = workoutDescriptionTextView.beginningOfDocument
            workoutDescriptionTextView.selectedTextRange = workoutDescriptionTextView.textRange(from: beginning, to: beginning)
            addButton.setTitle("Save", for: .normal)
        }
        #else
        if text != "" {
            workoutDescriptionTextView.text = text
            workoutDescriptionTextView.linkTextAttributes = [.foregroundColor: UIColor.systemBlue]
            workoutDescriptionTextView.isSelectable = true
            workoutDescriptionTextView.isEditable = false
            workoutDescriptionTextView.isUserInteractionEnabled = true
            workoutDescriptionTextView.dataDetectorTypes = .link
            addButton.isHidden = true
            cancelButton.isHidden = true
        }
        #endif
        setupSubviews()

    }
    
    
//    @objc func editWorkout() {
//        if let text = workoutDescriptionTextView.text {
//            self.onWorkoutSave?(text)
//            navigationController?.popViewController(animated: true)
//        }
//    }
    
   func setupSubviews() {
       workoutDescriptionTextView.delegate = self
       workoutDescriptionTextView.becomeFirstResponder()
       
        view.addSubviews(workoutDescriptionTextView, addButton, cancelButton)
       
       let buttonWidth = view.frame.width/2 - 30
       
       var textViewHeight: CGFloat {
           if text != "" {
               #if Admin
               return view.frame.height/3
               #else
               return view.frame.height * 0.9
               #endif
           } else {
               return view.frame.height/4
           }
       }
       
       var baseInset: CGFloat { return 15 }
       
       let constraints = [
        workoutDescriptionTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: baseInset),
        workoutDescriptionTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: baseInset),
        workoutDescriptionTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -baseInset),
        workoutDescriptionTextView.heightAnchor.constraint(equalToConstant: textViewHeight),
        
        addButton.topAnchor.constraint(equalTo: workoutDescriptionTextView.bottomAnchor, constant: baseInset),
        addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: baseInset),
        addButton.heightAnchor.constraint(equalToConstant: 44),
        addButton.widthAnchor.constraint(equalToConstant: buttonWidth),
//        addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
       
        
        cancelButton.topAnchor.constraint(equalTo: workoutDescriptionTextView.bottomAnchor, constant: baseInset),
        cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -baseInset),
        cancelButton.heightAnchor.constraint(equalTo: addButton.heightAnchor),
        cancelButton.widthAnchor.constraint(equalToConstant: buttonWidth)
        
       ]
       
       NSLayoutConstraint.activate(constraints)
   }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
