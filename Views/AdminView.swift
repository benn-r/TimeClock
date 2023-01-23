//
//  AdministrativeView.swift
//  CCGTime
//
//  Created by ben on 5/25/22.
//

import SwiftUI

struct AdminView: View {
    var body: some View {
        NavigationView {
            ZStack {
                
                Circle()
                    .frame(width: 50, height: 50, alignment: .center)
                
                
            }
            
            .navigationTitle("Admin")
        }
    }
}

struct AdministrativeView_Previews: PreviewProvider {
    static var previews: some View {
        AdminView()
    }
}
