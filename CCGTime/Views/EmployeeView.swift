//
//  Employee.swift
//  CCGTime
//
//  Created by ben on 5/25/22.
//

import SwiftUI

struct EmployeeView: View {
    
    @State var employeeDepartment = ""
    @State var selectedDepartment = "Select A Department"
    @FocusState var isInputActive: Bool
    @ObservedObject var employeeNumber = NumbersOnly()
    @ObservedObject var EmpModel = EmployeeModel()
    @ObservedObject var DeptModel = DepartmentModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(alignment: .center, spacing: 35) {

                    TextField("Employee ID Number", text: $employeeNumber.value)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .frame(width: 180)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .strokeBorder(.blue, lineWidth: 2)
                                .scaleEffect(1.75)
                        )
                        .focused($isInputActive)
                    
                        // Toolbar to create 'Done' button to close keyboard
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                Spacer()
                                
                                Button("Done") {
                                    isInputActive = false
                                }
                            }
                        }
                    
                            
                    Menu(selectedDepartment) {
                        ForEach(DeptModel.deptStrings, id: \.self) { item in
                            Button(item) {
                                self.selectedDepartment = item
                                self.employeeDepartment = item
                            }
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .strokeBorder(.blue, lineWidth: 2)
                            //.fill(Color.blue)
                            .scaleEffect(1.5)
                    )
                    
                    Spacer()
                        .frame(height: 15)
                            
                    Button("Clock In") {
                        let empNum = employeeNumber
                                
                        if (employeeDepartment != "") {
                            EmpModel.checkId(id: empNum) { idIsValid in
                                        
                                if (idIsValid) {
                                    let currentTime = Time.fancyTime()
                                    
                                    let timecard = EmployeeTimecard(employeeID: empNum.value)
                                    EmpModel.clockIn(timecard: timecard, department: employeeDepartment)
                                    EmpModel.get(id: empNum) { emp in
                                        Alert.message("Success!", "\(emp.name) has succesfully clocked in at \(currentTime).")
                                    }
                                }
                                else {
                                    if (empNum.value != "") {
                                        Alert.error("Employee ID Number \(empNum.value) does not exist.")
                                    }
                                    else {
                                        Alert.error("Please enter an ID number.")
                                    }
                                }
                            }
                        }
                        else {
                            Alert.error("Please select a department.")
                        }
                    }
                    .foregroundColor(Color.white)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.blue)
                            .scaleEffect(1.6)
                    )
                    Spacer()
                        .frame(height: 150)
                }
            }
            .navigationTitle("Clock In")
        }
    }
}

struct EmployeeView_Previews: PreviewProvider {
    static var previews: some View {
        EmployeeView()
    }
}
