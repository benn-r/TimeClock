//
//  DateView.swift
//  CCGTime
//
//  Created by ben on 7/16/22.
//

import SwiftUI
import OrderedCollections

struct DateView: View {
    
    var session: SessionStore
    private var dept: String
    private var date: String
    private var deptModel : DepartmentModel
    private var empModel : EmployeeModel
    @State private var timecardArray: [EmployeeTimecard] = []
    @State private var empName: String = ""
    
    init(session: SessionStore, dept: String, date: String) {
        self.dept = dept
        self.date = date
        
        self.session = session
        empModel = EmployeeModel(session: session)
        deptModel = DepartmentModel(session: session)
    }
    
    var body: some View {
        
        deptModel.getTimes(dept: dept, date: date) { tcArray in
            self.timecardArray = tcArray
            print("\(tcArray)")
        }
        
        return VStack {
            List {
                ForEach(timecardArray, id: \.self) { timecard in
                    Section(empModel.getName(id: timecard.getID(), withId: true)) {
                        
                        ForEach(0..<timecard.numOfEvents(), id: \.self) { index in
                            // For both of the scenarios I use the Time.dateView function
                            // to present the dates in the most readable format for users
                            if (index % 2 == 0) {
                                Text("**Clock-In:** \(Time.dateView(timecard.timecardEvents[index]))")
                            } else {
                                Text("**Clock-Out:** \(Time.dateView(timecard.timecardEvents[index]))")
                                Text("**Shift Length:** \(Time.distanceBetween(first: timecard.timecardEvents[index - 1], last: timecard.timecardEvents[index]))")
                                    .padding(.bottom)
                                    .padding(.top)
                            }
                            
                        }
                    }
                    .headerProminence(.increased)
                }
            }
        }
        .navigationTitle("\(deptModel.simpleDate(date))")
    }
}

struct DateView_Previews: PreviewProvider {
    static var previews: some View {
        DateView(session: SessionStore(), dept: "Alphabet", date: "03052024")
    }
}
