//
//  AboutViewController.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 26/4/23.
//

import UIKit

final class AboutViewController: UIViewController {
    
    // MARK: - Properties
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "coach")
        imageView.toAutoLayout()
        imageView.contentMode = .scaleAspectFill
        imageView.alpha = 0.3
        return imageView
    }()
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.toAutoLayout()
        textView.textColor = .white
        textView.isEditable = false
        textView.isSelectable = false
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.textAlignment = .justified
        return textView
    }()
    
    private let appDescription = "Welcome to our cosy fitness app! \n\nWe understand that you want to achieve your fitness goals with a personalized touch, and that's exactly what we provide. Our app is not just another AI-generated workout plan - we believe in the power of experience and empathy. \n\nMeet Roman Mezhov, our experienced coach with over 12 years of coaching in various activities, including cycle, hot iron, cross-training, and more. With almost a decade of experience in creating training programs, Roman has crafted unique and effective plans that cater to your individual needs and abilities. \n\nIn this app, you will have access to three monthly subscription training plans and two lifetime plans that will change your fitness game forever. The best part? Your coach is always available to answer your questions and provide feedback on your technique. Our commenting feature also allows you to share your progress with the coach and other users, creating a supportive community that encourages you every step of the way. \n\nOur Bodyweight plan is perfect for those who are always on-the-go, providing you with quick and effective workouts that require no special equipment. This plan is completely free, so there's no excuse not to get started today. \n\nOur ECD plan is the main training program, suitable for both beginners and intermediate-level athletes. With a full range of movements using common gym equipment, this well-balanced program will never leave you bored. \n\nOur Stryuach plan is for advanced athletes who are serious about pushing their limits and achieving visible progress. This plan is designed for competitive athletes who are in it to win it.By subscribing to this plan, you'll get a premium account with full access to all plans and features. \n\nIn addition to these plans, we also offer two plans with ten high-intensity workouts each - Belly Burner and Pelvic Power. These plans are specifically designed to strengthen the muscles of the press and pelvic muscles, respectively. \n\nBut that's not all - our app also gives you free access to our coach's blog, where you can read his thoughts and insights on working out and doing business in the fitness industry. In the Profile section, you can keep track of your personal records in weightlifting movements and share them with other users. \n\nJoin our community and achieve your fitness goals with the help of our expert coach and personalized training plans. Start your fitness journey with us today!".localized()
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .customDarkGray
        view.addSubview(imageView)
        
        let constraints = [
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        view.addSubview(textView)
        textView.text = appDescription
        textView.backgroundColor = .clear
        textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
}