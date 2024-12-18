//
//  GenerateReportView.swift
//  CCGTime
//
//  Created by ben on 12/17/24.
//

import SwiftUI

struct GenerateReportView: View {
    
    @Binding var showGenerateReportAlert: Bool
    @Binding var selectedStartDate: Date
    @Binding var selectedEndDate: Date
    @Binding var selectedDepartment: String
    @ObservedObject var deptModel: DepartmentModel
    
    var body: some View {
        NavigationView {
            Form {
                DatePicker(
                    "Start Date",
                    selection: $selectedStartDate,
                    displayedComponents: [.date]
                )
                
                DatePicker(
                    "End Date",
                    selection: $selectedEndDate,
                    displayedComponents: [.date]
                )
                
                Picker("Select Department", selection: $selectedDepartment) {
                    Text("Select a Department").tag("")
                    ForEach(deptModel.deptStrings, id: \.self) { dept in
                        Text(dept)
                    }
                }
            }
            .navigationTitle("Generate Report")
            .navigationBarItems(
                leading: Button("Cancel") {
                    showGenerateReportAlert = false
                },
                trailing: Button("Generate") {
                    if !selectedDepartment.isEmpty {
                        deptModel.generateReport(
                            selectedDepartment: selectedDepartment,
                            startDate: selectedStartDate,
                            endDate: selectedEndDate
                        )
                        showGenerateReportAlert = false
                    }
                }
            )
        }
    }
}

#Preview {
    //GenerateReportView()
}
