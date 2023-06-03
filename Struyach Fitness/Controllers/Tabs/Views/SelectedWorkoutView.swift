//
//  SelectedWorkoutHeaderView.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 8/2/23.
//

import UIKit

final class SelectedWorkoutView: UIView, UITextViewDelegate {
    
    //MARK: - Properties
    
    private var baseInset: CGFloat { return 15 }
    private var innerInset: CGFloat { return 10 }
    
    private let backgroundView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .top
        view.clipsToBounds = true
        view.alpha = 0.8
        view.toAutoLayout()
        return view
    }()
    
    private let workoutView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.alpha = 0.8
        view.toAutoLayout()
        return view
    }()
    
    let workoutDescriptionTextView: UITextView = {
        let textView = UITextView()
        textView.sizeToFit()
        textView.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        textView.textColor = .black
        textView.textAlignment = .left
        textView.isEditable = false
        textView.linkTextAttributes = [.foregroundColor: UIColor.systemBlue]
        textView.isSelectable = true
        textView.backgroundColor = .white
        textView.isUserInteractionEnabled = true
        textView.isScrollEnabled = true
        textView.dataDetectorTypes = .link
        textView.toAutoLayout()
        return textView
    }()
    
    // MARK: - Lifecycle
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        randomizeBackgroungImages()
    }
    
    //MARK: - Methods
    
    private func setupSubviews() {
        self.addSubviews(backgroundView, workoutView)
        workoutView.addSubview(workoutDescriptionTextView)
 
        let constraints = [
            backgroundView.topAnchor.constraint(equalTo: self.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            workoutView.topAnchor.constraint(equalTo: backgroundView.topAnchor),
            workoutView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor),
            workoutView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor),
            workoutView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor),

            workoutDescriptionTextView.topAnchor.constraint(equalTo: workoutView.topAnchor, constant: innerInset),
            workoutDescriptionTextView.leadingAnchor.constraint(equalTo: workoutView.leadingAnchor, constant: innerInset),
            workoutDescriptionTextView.trailingAnchor.constraint(equalTo: workoutView.trailingAnchor, constant: -innerInset),
            workoutDescriptionTextView.bottomAnchor.constraint(equalTo: workoutView.bottomAnchor, constant: -innerInset),
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    /// This function makes background images random from ImagesStorage
    func randomizeBackgroungImages () {
        let backgroundImages = ImageStorage.imageArray
        let randomIndex = Int.random(in: 0..<backgroundImages.count)
        if let backgroundImage = backgroundImages[randomIndex]
        {
            backgroundView.image = backgroundImage
        }
    }
}
