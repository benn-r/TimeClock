//
//  GenerateReportView.swift
//  CCGTime
//
//  Created by ben on 12/17/24.
//

import SwiftUI

struct GenerateReportView: View {
    
    @EnvironmentObject var departmentModel: DepartmentModel
    
    @State private var showDepartmentAlert: Bool = false
    @State private var showDateRangeAlert: Bool = false
    
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
                    in: selectedStartDate...Date(),
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
                    // Check if date range is logical
                    if selectedStartDate > selectedEndDate {
                        showDateRangeAlert = true
                    } else {
                        // Check if a department was selected
                        if selectedDepartment.isEmpty {
                            showDepartmentAlert = true
                        } else {
                            departmentModel.generateReport(
                                selectedDepartment: selectedDepartment,
                                startDate: selectedStartDate,
                                endDate: selectedEndDate
                            )
                            showGenerateReportAlert = false
                        }
                    }
                }
            )
            .alert(Text("Error"), isPresented: $showDepartmentAlert) {} message: {
                Text("Please select a department")
            }
            .alert(Text("Error"), isPresented: $showDateRangeAlert) {} message: {
                Text("Starting date must be before end date")
            }
        }
    }
}

#Preview {
    //GenerateReportView()
}
