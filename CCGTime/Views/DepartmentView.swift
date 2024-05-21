//
//  DepartmentView.swift
//  CCGTime
//
//  Created by ben on 7/16/22.
//

import SwiftUI

struct DepartmentView: View {
    
    @ObservedObject var DeptModel : DepartmentModel
    @State var dateArray: [String] = []
    let dept: String
    
    var session: SessionStore
    
    init(session: SessionStore, dept: String) {
        self.dept = dept
        self.session = session
        DeptModel = DepartmentModel(session: session)
    }
    
    var body: some View {
        
        let _ = DeptModel.getDates(dept: dept) { dates in
            self.dateArray = dates
        }
        
        return VStack(alignment: .center) {
            
            List {
                ForEach(dateArray, id: \.self) { item in
                    NavigationLink(destination: DateView(session: session, dept: dept, date: item)) {
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
        DepartmentView(session: SessionStore(), dept: "MargaritaVille")
    }
}
