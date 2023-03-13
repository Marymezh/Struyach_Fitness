//
//  SelectedWorkoutHeaderView.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 8/2/23.
//

import UIKit

class SelectedWorkoutView: UIView, UITextViewDelegate {
    
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
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.toAutoLayout()
        return scrollView
    }()
    
    private let workoutView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.cornerRadius = 5
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowRadius = 5
        view.layer.shadowOffset = CGSize(width: 5, height: 5)
        view.layer.shadowOpacity = 0.7
        view.alpha = 0.8
        view.toAutoLayout()
        return view
    }()
    
    let workoutDescriptionTextView: UITextView = {
        let textView = UITextView()
        textView.sizeToFit()
        textView.font = UIFont.systemFont(ofSize: 15, weight: .regular)
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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupSubviews()
        randomizeBackgroungImages()
        
    }
    
    private func setupSubviews() {
        
        self.addSubview(backgroundView)
        backgroundView.addSubview (workoutView)
        workoutView.addSubview (scrollView)
        scrollView.addSubview(workoutDescriptionTextView)
        
        let constraints = [
            
            backgroundView.topAnchor.constraint(equalTo: self.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            workoutView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: baseInset),
            workoutView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: baseInset),
            workoutView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -baseInset),
            workoutView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -baseInset),

            scrollView.topAnchor.constraint(equalTo: workoutView.topAnchor, constant: innerInset),
            scrollView.leadingAnchor.constraint(equalTo: workoutView.leadingAnchor, constant: innerInset),
            scrollView.trailingAnchor.constraint(equalTo: workoutView.trailingAnchor, constant: -innerInset),
            scrollView.bottomAnchor.constraint(equalTo: workoutView.bottomAnchor, constant: -innerInset),
            
            workoutDescriptionTextView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            workoutDescriptionTextView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            workoutDescriptionTextView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            workoutDescriptionTextView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            workoutDescriptionTextView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func randomizeBackgroungImages () {
        /// This function makes background images random from ImagesStorage
        let backgroundImages = ImageStorage.imageArray
        let randomIndex = Int.random(in: 0..<backgroundImages.count)
        if let backgroundImage = backgroundImages[randomIndex]
        {
            backgroundView.image = backgroundImage
        }
    }
}
