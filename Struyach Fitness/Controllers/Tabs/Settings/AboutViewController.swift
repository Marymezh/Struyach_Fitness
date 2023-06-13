//
//  AboutViewController.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 26/4/23.
//

import UIKit

final class AboutViewController: UIViewController {
    
    // MARK: - Properties
    
    let text: String?
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
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
    
   
    
    // MARK: - Lifecycle
    
    init(text: String) {
        self.text = text
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        textView.text = text
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
