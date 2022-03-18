//
//  AppDelegate.swift
//  IphoneIpadFirebase
//
//  Created by Zelxius on 16/03/22.
//

import UIKit
import Firebase

class AppDelegate: NSObject, UIApplicationDelegate{
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

