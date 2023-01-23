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
                    Section(EmpModel.getName(id: timecard.getID())) {
                        if (!timecard.hasClockedOut()) {
                            Text("Clock-In:\t\t\t\t \(timecard.getTimeIn())")
                        }
                        else {
                            Text("Clock-In:\t\t\t\t \(timecard.getTimeIn())")
                            Text("Clock-Out:\t\t\t\t \(timecard.getTimeOut())")
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
