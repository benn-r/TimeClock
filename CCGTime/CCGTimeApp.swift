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
            if user.user == nil || user.departmentModel == nil || user.employeeModel == nil {
                ProgressView()
            } else if user.activeSession == false {
                LoginView()
                    .environmentObject(user)
            } else {
                ViewController()
                    .environmentObject(user)
                    .environmentObject(user.departmentModel!)
                    .environmentObject(user.employeeModel!)
            }
        }
    }
}
