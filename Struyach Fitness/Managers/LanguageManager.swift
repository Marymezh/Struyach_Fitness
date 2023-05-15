//
//  LanguageManager.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 4/5/23.
//

import Foundation

class LanguageManager {
    
    static let shared = LanguageManager()
    public var currentLanguage: Language {
        didSet {
            // Save the new language preference to UserDefaults
            UserDefaults.standard.setValue(currentLanguage.rawValue, forKey: "language")
            UserDefaults.standard.synchronize()
            print("saved language in User defaults is \(currentLanguage)")
        }
    }
    
    public var localeId: String {
            switch currentLanguage {
            case .english:
                return "en_US"
            case .russian:
                return "ru_RU"
            }
    }
    
    private init() {
        let savedLanguage = UserDefaults.standard.string(forKey: "language")
        if let language = Language(rawValue: savedLanguage ?? "") {
            currentLanguage = language
            print ("setting selected language")
        } else {
            // Use the system language if no language preference is set
            let systemLanguageCode = Locale.current.languageCode ?? Language.english.rawValue
            currentLanguage = Language(rawValue: systemLanguageCode)!
            print("setting default language")
        }
    }
    
    func getCurrentLanguage() -> Language {
        return currentLanguage
    }
    
    func setCurrentLanguage(_ language: Language) {
        currentLanguage = language
        print ("language is set to \(currentLanguage)")
    }
}
