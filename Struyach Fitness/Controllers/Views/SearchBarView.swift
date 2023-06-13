//
//  SearchBarView.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 28/4/23.
//

import UIKit

class SearchBarView: UIView {

    let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for workouts".localized()
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundColor = .customDarkGray
        searchBar.searchTextField.textColor = .customDarkGray
        searchBar.searchTextField.backgroundColor = .white
        searchBar.barTintColor = .customDarkGray
        searchBar.tintColor = .customDarkGray
        searchBar.clipsToBounds = true
        searchBar.showsCancelButton = true
        searchBar.isHidden = true
        searchBar.toAutoLayout()
        return searchBar
    }()
    
    //MARK: - Lifecycle

    init() {
           super.init(frame: .zero)
        setupSubviews()
       }

       required init?(coder: NSCoder) {
           fatalError("init(coder:) has not been implemented")
       }
    
   private func setupSubviews() {
        self.addSubview(searchBar)
        
        let constraints = [
            searchBar.topAnchor.constraint(equalTo: self.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            searchBar.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }

}
