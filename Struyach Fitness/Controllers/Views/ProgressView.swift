//
//  ProgressView.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 21/4/23.
//

import UIKit

final class ProgressView: UIView {
    
    //MARK: - Properties
    
    var progressBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.7
        view.toAutoLayout()
        return view
    }()
    
    var progressView: UIProgressView = {
        let view = UIProgressView(progressViewStyle: .default)
        view.progress = 0
        view.progressTintColor = ColorManager.shared.appColor
        view.trackTintColor = .white
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        view.toAutoLayout()
        return view
    }()
    
    var progressLabel: UILabel = {
        let label  = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.toAutoLayout()
        return label
    }()

    // MARK: - Lifecycle
    
    init() {
           super.init(frame: .zero)
        setupSubviews()
        self.isHidden = true
       }

       required init?(coder: NSCoder) {
           fatalError("init(coder:) has not been implemented")
       }
    
    // MARK: - Methods
    
    private func setupSubviews() {
        self.addSubviews(progressBackgroundView, progressView, progressLabel)

        let constraints = [
            progressBackgroundView.topAnchor.constraint(equalTo: self.topAnchor),
            progressBackgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            progressBackgroundView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            progressBackgroundView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            progressView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            progressView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            progressView.widthAnchor.constraint(equalToConstant: 200),
            progressView.heightAnchor.constraint(equalToConstant: 12),
            progressLabel.centerXAnchor.constraint(equalTo: self.progressView.centerXAnchor),
            progressLabel.bottomAnchor.constraint(equalTo: self.progressView.topAnchor, constant: -10)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func showProgress(progressLabelText: String, percentComplete: Float){
        self.isHidden = false
        self.progressView.progress = percentComplete
        self.progressLabel.text = progressLabelText
    }
    
    func hide(){
    self.isHidden = true
    }

}
