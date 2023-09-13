//
//  ExtensionsUITextView.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 17.08.2023.
//

import Foundation
import UIKit

class MyTextView: UITextView {
    override var canBecomeFirstResponder: Bool {
        return false
    }
    
    func makeSecure() {
           DispatchQueue.main.async {
               let field = UITextField()
               field.isSecureTextEntry = true
               self.addSubview(field)
               field.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
               field.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
               self.layer.superlayer?.addSublayer(field.layer)
               field.layer.sublayers?.first?.addSublayer(self.layer)
           }
       }
}








