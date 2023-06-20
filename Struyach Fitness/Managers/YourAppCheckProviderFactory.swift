//
//  YourAppCheckProviderFactory.swift
//  Struyach Fitness
//
//  Created by Мария Межова on 20.06.2023.
//

import Foundation
import Firebase
import FirebaseAppCheck

class YourAppCheckProviderFactory: NSObject, AppCheckProviderFactory {
  func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
    if #available(iOS 14.0, *) {
      return AppAttestProvider(app: app)
    } else {
      return DeviceCheckProvider(app: app)
    }
  }
}
