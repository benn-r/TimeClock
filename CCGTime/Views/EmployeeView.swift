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
    
    // Function to check if employee is clocking into the correct department
    func empCorrectDept(_ empId: NumbersOnly, _ selectedDept: String) -> Bool {
        
        let correctDept = EmpModel.getDept(id: empId)
        
        if (selectedDept == correctDept) {
            return true
        }
        else {
            return false
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(alignment: .center, spacing: 35) {

                    // TextField for employees to enter their ID number into
                    // Value is saved under employeeNumber.value
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
                        let selectedDept = employeeDepartment
                                
                        // Check if user selected a department
                        if (employeeDepartment == "") {
                            Alert.error("Please select a department.")
                        }
                        // Check if user entered an employee ID
                        else if (empNum.value == "") {
                            Alert.error("Please enter an ID number.")
                        }
                        // If both are true then continue
                        else {
                            
                            EmpModel.checkId(id: empNum) { idIsValid in
                                
                                // First check that employee and department
                                // selection are correct
                                var correctInfo: Bool = true
                                
                                if (!idIsValid) {
                                    correctInfo = false
                                    Alert.error("Employee ID Number \(empNum.value) does not exist.")
                                    
                                } else {
                                    // Check if employee selected correct department
                                    // Need to ensure that the id is valid first, or
                                    // empCorrectDept() will throw a runtime error
                                    
                                    if (!empCorrectDept(empNum, selectedDept)) {
                                        
                                        correctInfo = false
                                        
                                        let empDept = EmpModel.getDept(id: empNum)
                                        
                                        Alert.error("Employee \(empNum.value) is assigned to department \(empDept), not \(selectedDept)")
                                    }
                                }
                                    
                                    
                                
                                if (correctInfo) {
                                    
                                    EmpModel.isClockedIn(id: empNum.value, dept: selectedDept) { isClockedIn in

                                        if (!isClockedIn) {
                                            let currentTime = Time.fancyTime()
                                            
                                            //let timecard = EmployeeTimecard(id:empNum, dept:selectedDept)
                                            
                                            EmpModel.clockIn(id: empNum.value, department: employeeDepartment)
                                            
                                            EmpModel.get(id: empNum) { emp in
                                                Alert.message("Success!", "\(emp.name) has succesfully clocked in at \(currentTime).")
                                            }
                                        }
                                        else if (isClockedIn) {
                                            
                                            let currentTime = Time.fancyTime()
                                            
                                            
                                            EmpModel.clockOut(id: empNum.value, department:selectedDept)
                                            
                                            EmpModel.get(id: empNum) { emp in
                                                Alert.message("Success!", "\(emp.name) has succesfully clocked out at \(currentTime).")
                                            }
                                        }
                                    }
                                }
                            }
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
