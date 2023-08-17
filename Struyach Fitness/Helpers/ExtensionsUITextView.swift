//
//  ExtensionsUITextView.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 17.08.2023.
//

import Foundation
import UIKit


//extension UITextView {
//    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
//        if action == #selector(UIResponderStandardEditActions.copy(_:)) {
//            return false
//        }
//        return super.canPerformAction(action, withSender: sender)
//    }
//}

class MyTextView: UITextView {
    override open func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.copy(_:)) {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
}
