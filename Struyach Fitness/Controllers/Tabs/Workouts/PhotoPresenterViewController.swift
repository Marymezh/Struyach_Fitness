//
//  PhotoPresenterViewController.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 23/3/23.
//

import UIKit
import SDWebImage

final class PhotoPresenterViewController: UIViewController {
    
    //TODO: pinch to enlarge photos
    //MARK: - Properties
    
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
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.toAutoLayout()
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
        button.tintColor = .white
        button.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
        button.addTarget(self, action: #selector(closeScreen), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Lifecycle
    
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
        setupGestureRecognizer()
    }
    
    deinit {
           print ("photo presenter is deallocated")
       }
    
    
    //MARK: - Setup subviews
    
    private func setupSubviews() {
        view.addSubviews(backgroundView, imageView, closeButton)

        let constraints = [
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            closeButton.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 15),
            closeButton.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -15),
            closeButton.heightAnchor.constraint(equalToConstant: 40),
            closeButton.widthAnchor.constraint(equalTo: closeButton.heightAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setupGestureRecognizer() {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        imageView.addGestureRecognizer(pinchGesture)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        imageView.addGestureRecognizer(panGesture)
        imageView.isUserInteractionEnabled = true
    }
    
    @objc private func handlePinch(_ gestureRecognizer: UIPinchGestureRecognizer) {
        if let view = gestureRecognizer.view {
            view.transform = view.transform.scaledBy(x: gestureRecognizer.scale, y: gestureRecognizer.scale)
            gestureRecognizer.scale = 1.0
        }
    }
    
    @objc private func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let view = gestureRecognizer.view else { return }
        let translation = gestureRecognizer.translation(in: view.superview)
        view.center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
        gestureRecognizer.setTranslation(CGPoint.zero, in: view.superview)
    }
    
    @objc private func closeScreen() {
        self.dismiss(animated: true)
    }
}

