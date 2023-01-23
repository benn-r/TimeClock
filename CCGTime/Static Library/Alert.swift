//
//  Alert.swift
//  CCGTime
//
//  Created by ben on 5/28/22.
//

import Foundation
import SwiftUI

class Alert {
    
    class func error(_ message: String) {
        let alertVC = UIAlertController(title: "Error!",
                                        message: message,
                                        preferredStyle: .alert)
        
        let acknowledgeAction = UIAlertAction(title: "Ok", style: .default)
        alertVC.addAction(acknowledgeAction)
        
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first?.rootViewController
        window?.present(alertVC, animated: true)
    }
    
    class func message(_ header: String, _ message: String) {
        let alertVC = UIAlertController(title: header,
                                        message: message,
                                        preferredStyle: .alert)
        
        let acknowledgeAction = UIAlertAction(title: "Ok", style: .default)
        alertVC.addAction(acknowledgeAction)
        
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first?.rootViewController
        window?.present(alertVC, animated: true)
    }
    
    class func newDept() {
        let alertVC = UIAlertController(title: "Create New Department",
                                        message: "Enter new department name",
                                        preferredStyle: .alert)
        
        alertVC.addTextField { newDept in newDept.placeholder = "New Department" }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        let submitAction = UIAlertAction(title: "Create", style: .default){ (action: UIAlertAction) in
            let newDept: String = alertVC.textFields![0].text!
            let DeptModel = DepartmentModel()
            DeptModel.createDepartment(newDept)
        }
        
        alertVC.addAction(cancelAction)
        alertVC.addAction(submitAction)
            
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first?.rootViewController
        window?.present(alertVC, animated: true)
    }
}
