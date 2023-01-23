//
//  DepartmentView.swift
//  CCGTime
//
//  Created by ben on 7/16/22.
//

import SwiftUI

struct DepartmentView: View {
    
    @ObservedObject var DeptModel = DepartmentModel()
    let dept: String
    @State var dateArray: [String] = []
    
    var body: some View {
        
        let _ = DeptModel.getDates(dept: dept) { dates in
            self.dateArray = dates
        }
        
        return VStack(alignment: .center) {
            
            List {
                ForEach(dateArray, id: \.self) { item in
                    NavigationLink(destination: DateView(dept: dept, date: item)) {
                        Text(DeptModel.fancyDate(item))
                    }
                }
            }
        }
        .navigationTitle(dept)
    }
}



struct DepartmentView_Previews: PreviewProvider {
    static var previews: some View {
        DepartmentView(dept: "MargaritaVille")
    }
}
