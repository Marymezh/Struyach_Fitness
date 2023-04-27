//
//  OtherOptionsViewController.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 27/4/23.
//

import UIKit

class OtherOptionsViewController: UIViewController {
    
    private var smallInset: CGFloat { return 16 }
    private var bigInset: CGFloat { return 32 }
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.systemGreen
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.textAlignment = .center
        label.text = "OUR PAID TRAINING PLANS"
        label.adjustsFontSizeToFitWidth = true
        label.toAutoLayout()
        return label
    }()
    
    let descriptionTextView: UITextView = {
        let view = UITextView()
        view.textColor = UIColor.white
        view.backgroundColor = .customDarkGray
        view.font = UIFont.systemFont(ofSize: 16)
        view.isEditable = false
        view.isSelectable = false
        view.textAlignment = .left
        view.text = "ECD Plan, the main training program followed by our ECD Fitness Club, is suitable for both beginners and intermediate-level athletes. With a well-balanced program of full range movements using common gym equipment, you'll never get bored. \n\nPlus, you'll have the opportunity to share your progress with a coach and other users and compare results. \n\nSubscription price - $1.19/month \n\n\nStruyach plan is designed for advanced athletes who are serious about pushing their limits and achieving visible progress. This plan is designed for competitive athletes who are in it to win it.\n\nBy subscribing to this plan, you'll get a premium account with full access to all plans and lifetime access to the Badass and Hard press plans! \n\nSubscription price - $9.99/month \n\n\nPelvic Power Plan offers 10 high-intensity workouts with detailed movement descriptions and video presentations to help you tone and strengthen your pelvic muscles. \n\nPlus, you'll have access to a personal coach for any questions you may have, just leave a comment under the workout! \n\nLifetime access - $2.99 \n\n\nOur high-intensity Belly Burner Plan offers 10 unique workouts with detailed descriptions and video presentations. \n\nGet rid of stubborn belly fat and achieve a leaner, fitter body with the help of a personal coach who will answer any questions you have. \n\nLifetime access - $2.99"
        view.toAutoLayout()
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .customDarkGray
        view.addSubview(titleLabel)
        view.addSubview(descriptionTextView)
        
        let constraints = [
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: bigInset),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: smallInset),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -smallInset),
            
            descriptionTextView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: smallInset),
            descriptionTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: smallInset),
            descriptionTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -smallInset),
            descriptionTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -smallInset)
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
