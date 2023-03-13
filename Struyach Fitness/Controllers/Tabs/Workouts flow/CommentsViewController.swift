//
//  CommentsViewController.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 13/3/23.
//

import UIKit

class CommentsViewController: UIViewController {
    
    private let workout: Workout
    
    private let workoutView: UITextView = {
        let textView = UITextView()
        textView.toAutoLayout()
        return textView
    }()
    
    init (workout: Workout) {
        self.workout = workout
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
            view.backgroundColor = .cyan
        view.addSubview(workoutView)
        
        workoutView.text = workout.description
 
        
        let constraints = [
            workoutView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            workoutView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            workoutView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            workoutView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        
    }
}
