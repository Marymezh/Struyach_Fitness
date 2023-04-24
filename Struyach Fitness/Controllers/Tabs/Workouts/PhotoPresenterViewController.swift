//
//  PhotoPresenterViewController.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 23/3/23.
//

import UIKit
import SDWebImage

class PhotoPresenterViewController: UIViewController {
    
    private let url: URL
    
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.8
        view.toAutoLayout()
        return view
    }()
    
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.alpha = 1
        view.toAutoLayout()
        return view
    }()
    
    init (url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        imageView.sd_setImage(with: self.url)
    }
    
    private func setupSubviews() {
        view.addSubviews(backgroundView, imageView)

        let constraints = [
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
}
