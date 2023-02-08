//
//  ExtensionsUIView.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 8/2/23.
//


import Foundation
import UIKit

extension UIView {
    func toAutoLayout() {
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}

extension UIView {
    func addSubviews(_ subviews: UIView...) {
        subviews.forEach { addSubview($0) }
    }
}
