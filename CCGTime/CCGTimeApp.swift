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
    
    @StateObject var user = SessionStore()
    
    var body: some Scene {
        WindowGroup {
            // If user object has not fully initialized, show a loading screen
            if  user.hasLoaded == false {
                ProgressView()
            // If user object is initialized but there is no active session, show log in screen
            } else if user.hasActiveSession == false {
                LoginView()
                    .environmentObject(user)
            // If user object is initialized and has an active session, show main screen
            } else {
                ViewController()
                    .environmentObject(user)
                    .environmentObject(user.departmentModel!)
                    .environmentObject(user.employeeModel!)
            }
        }
    }
}
