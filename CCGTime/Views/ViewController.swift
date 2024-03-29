//
//  ViewController.swift
//  CCGTime
//
//  Created by Ben Rosario on 5/25/22.
//

import SwiftUI
import Combine

struct ViewController: View {
    
    var body: some View {
        TabView {
            EmployeeView()
                .tabItem {
                    Image(systemName: "clock")
                        Text("Clock In")
                }
            
            ManagerView()
                .tabItem {
                    Image(systemName: "person.crop.circle.fill")
                        Text("Manager")
                }
                    
        }
    }
}
    

struct ViewController_Previews: PreviewProvider {
    static var previews: some View {
        ViewController()
    }
}

// NumbersOnly
// Used to restrict text input to only filtered keywords
// Used in creating new employees to ensure employeeIDs are only composed of digits
// Maybe move to seperate file?

class NumbersOnly: ObservableObject {
    @Published var value = "" {
        didSet {
            let filtered = value.filter { "0123456789".contains($0) }
            
            if value != filtered {
                value = filtered
            }
        }
    }
}

// FloatsOnly
// Used to restrict text input to only filtered keywords
// Rework needed, as I believe you can insert multiple periods (.) in one field
// Maybe move to seperate file?

class FloatsOnly: ObservableObject {
    @Published var value = "" {
        didSet {
            let filtered = value.filter { "0123456789.".contains($0) }
            
            if value != filtered {
                value = filtered
            }
        }
    }
}
