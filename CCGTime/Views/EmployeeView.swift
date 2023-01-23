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
                        .frame(width: 200)
                        .buttonBorderShape(
                            ButtonBorderShape.roundedRectangle(radius: 3.5)
                        )
                            
                    Menu(selectedDepartment) {
                        ForEach(DeptModel.departments, id: \.self) { item in
                            Button(item) {
                                self.selectedDepartment = item
                                self.employeeDepartment = item
                            }
                        }
                    }
                            
                    Button("Clock In") {
                        let empNum = employeeNumber
                                
                        if (employeeDepartment != "") {
                            EmpModel.checkId(id: empNum) { idIsValid in
                                        
                                if (idIsValid) {
                                    //Alert.clockInSuccess()
                                    let timecard = EmployeeTimecard(employeeID: empNum.value)
                                    EmpModel.clockIn(timecard: timecard, department: employeeDepartment)
                                    EmpModel.get(id: empNum) { emp in
                                        Alert.message("Success!", "\(emp.name) has succesfully clocked in at currentTime.")
                                    }
                                }
                                else {
                                    if (empNum.value != "") {
                                        Alert.error("ID Number \(empNum.value) does not exist.")
                                    }
                                    else {
                                        Alert.error("Please enter an ID number.")
                                    }
                                    //Alert.clockInFail()
                                }
                            }
                        }
                        else {
                            Alert.error("Please select a department!")
                        }
                    }
                    .foregroundColor(Color.white)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.blue)
                            .scaleEffect(1.5)
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
