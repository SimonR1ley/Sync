//
//  SyncApp.swift
//  Sync
//
//  Created by Simon Riley on 2023/08/02.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
      print("firebase configuration successfull")
    return true
  }
}

@main
struct SyncApp: App {
    
   
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            SplashScreen()
        }
    }
}
