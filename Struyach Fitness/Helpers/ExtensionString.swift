//
//  ExtensionString.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 1/5/23.
//

import Foundation

extension String {
    func localized() -> String {
        let currentLanguage = UserDefaults.standard.string(forKey: "language")
        let path = Bundle.main.path(forResource: currentLanguage, ofType: "lproj")
        let bundle = Bundle(path: path!)
        return NSLocalizedString(self,
                                 tableName: "Localizable",
                                 bundle: bundle!,
                                 value: self,
                                 comment: self)
    }
}
