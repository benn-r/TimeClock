//
//  ContentView.swift
//  CCGTime
//
//  Created by ben on 5/25/22.
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
                    
            AdminView()
                .tabItem {
                    Image(systemName: "eye.circle.fill")
                        Text("Admin")
                }
                    
        }
    }
}
    

struct ViewController_Previews: PreviewProvider {
    static var previews: some View {
        ViewController()
    }
}


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
