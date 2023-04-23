//
//  ExtensionDate.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 22/4/23.
//

import Foundation
import UIKit

extension Date {
    func formattedString(dateFormat: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateFormat = dateFormat
        return formatter.string(from: self)
    }
}
