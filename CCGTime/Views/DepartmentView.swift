//
//  DepartmentView.swift
//  CCGTime
//
//  Created by ben on 7/16/22.
//

import SwiftUI

struct DepartmentView: View {
    
    @ObservedObject private var deptModel : DepartmentModel
    @State private var dateArray: [String] = []
    private let dept: String
    
    var session: SessionStore
    
    init(session: SessionStore, dept: String) {
        self.dept = dept
        self.session = session
        deptModel = DepartmentModel(session: session)
    }
    
    var body: some View {
        
        let _ = deptModel.getDates(dept: dept) { dates in
            self.dateArray = dates
        }
        
        return VStack(alignment: .center) {
            
            List {
                ForEach(dateArray, id: \.self) { item in
                    NavigationLink(destination: DateView(session: session, dept: dept, date: item)) {
                        Text(deptModel.fancyDate(item))
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
