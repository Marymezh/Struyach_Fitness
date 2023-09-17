//
//  ColorManager.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 15.09.2023.
//

import Foundation
import UIKit

final class ColorManager {
    
    static let shared = ColorManager()
    private let selectedColor = UserDefaults.standard.colorForKey(key: "SelectedColor")
    public lazy var appColor = selectedColor ?? .systemGreen
    
    private init() {}
    
}
