//
//  SecurityCodeChecker.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 17/5/23.
//

import Foundation


final class SecurityCodeChecker {
    static let shared = SecurityCodeChecker()
    
    private var savedCode: String {
      get {
        guard let filePath = Bundle.main.path(forResource: "Admin-Info", ofType: "plist") else {
          fatalError("Couldn't find file 'Admin-Info.plist'.")
        }
        let plist = NSDictionary(contentsOfFile: filePath)
        guard let value = plist?.object(forKey: "AccessKey") as? String else {
          fatalError("Couldn't find key 'AccessKey' in 'Admin-Info.plist'.")
        }
        return value
      }
    }
    
    private init() {}
    
    
    public func check(enteredCode: String, completion: @escaping (Bool) -> ()) {
        if enteredCode == savedCode {
            completion(true)
        } else {
            completion(false)
        }
    }
    
    
    


}
