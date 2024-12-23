//
//  GenerateReportView.swift
//  CCGTime
//
//  Created by ben on 12/17/24.
//

import SwiftUI

struct GenerateReportView: View {
    
    @EnvironmentObject var departmentModel: DepartmentModel
    
    @Binding var showGenerateReportAlert: Bool
    @Binding var selectedStartDate: Date
    @Binding var selectedEndDate: Date
    @Binding var selectedDepartment: String
    
    var earliestDate: Date
    
    var body: some View {
        NavigationView {
            Form {
                DatePicker(
                    "Start Date",
                    selection: $selectedStartDate,
                    in: earliestDate...Date(),
                    displayedComponents: [.date]
                )
                
                DatePicker(
                    "End Date",
                    selection: $selectedEndDate,
                    displayedComponents: [.date]
                )
                
                Picker("Select Department", selection: $selectedDepartment) {
                    Text("Select a Department").tag("")
                    ForEach(departmentModel.deptStrings, id: \.self) { dept in
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
                        departmentModel.generateReport(
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
