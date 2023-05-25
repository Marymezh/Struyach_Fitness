//
//  ExtensionUISwitch.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 22/5/23.
//

import Foundation
import UIKit

extension UISwitch {
    private static var programNameKey: UInt8 = 0

    var programName: String? {
        get {
            return objc_getAssociatedObject(self, &UISwitch.programNameKey) as? String
        }
        set {
            objc_setAssociatedObject(self, &UISwitch.programNameKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
