//
//  CCGTimeApp.swift
//  CCG Time
//
//  Created by ben on 5/25/22.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {

  func application(_ application: UIApplication,

                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

    FirebaseApp.configure()

    return true

  }
}

@main
struct CCGTimeApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            ViewController()
        }
    }
}
