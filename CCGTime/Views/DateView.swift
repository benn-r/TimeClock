//
//  DateView.swift
//  CCGTime
//
//  Created by ben on 7/16/22.
//

import SwiftUI
import OrderedCollections

struct DateView: View {
    
    let dept: String
    let date: String
    let DeptModel = DepartmentModel()
    let EmpModel = EmployeeModel()
    @State var timecardArray: [EmployeeTimecard] = []
    @State var empName: String = ""
    
    var body: some View {
        
        DeptModel.getTimes(dept: dept, date: date) { tcArray in
            self.timecardArray = tcArray
            print("\(tcArray)")
        }
        
        return VStack {
            List {
                ForEach(timecardArray, id: \.self) { timecard in
                    Section(EmpModel.getName(id: timecard.getID(), withId: true)) {
                        
                        ForEach(0..<timecard.numOfEvents(), id: \.self) { index in
                            // For both of the scenarios I use the Time.dateView function
                            // to present the dates in the most readable format for users
                            if (index % 2 == 0) {
                                Text("**Clock-In:** \(Time.dateView(timecard.timecardEvents[index]))")
                            } else {
                                Text("**Clock-Out:** \(Time.dateView(timecard.timecardEvents[index]))")
                                Text("**Shift Length:** \(Time.distanceBetween(first: timecard.timecardEvents[index - 1], last: timecard.timecardEvents[index]))")
                                    .padding(.bottom)
                            }
                        }
                    }
                    .headerProminence(.increased)
                }
            }
        }
        .navigationTitle("\(DeptModel.simpleDate(date))")
    }
}

struct DateView_Previews: PreviewProvider {
    static var previews: some View {
        DateView(dept: "MargaritaVille", date: "20220715")
    }
}
