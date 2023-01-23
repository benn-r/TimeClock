//
//  AddEmployeeView.swift
//  CCGTime
//
//  Created by ben on 5/25/22.
//

import SwiftUI

struct AddEmployeeView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State private var employeeFirstname = ""
    @State private var employeeLastname = ""
    @State private var employeeDepartment = ""
    @ObservedObject private var employeeNumber = NumbersOnly()
    @ObservedObject private var employeeWage = FloatsOnly()
    @ObservedObject private var EmpModel = EmployeeModel()
    @ObservedObject private var DeptModel = DepartmentModel()
    
    func clearForm() {
        self.employeeFirstname = ""
        self.employeeLastname = ""
        self.employeeDepartment = ""
        self.employeeNumber.value = ""
        self.employeeWage.value = ""
    }
    
    func formIsValid() -> Bool {
        
        if self.employeeFirstname == "" { return false }
        else if self.employeeLastname == "" { return false }
        else if self.employeeDepartment == "" { return false }
        else if self.employeeNumber.value == "" { return false }
        else if self.employeeWage.value == "" { return false }
        else { return true }
        
    }
    
    var body: some View {
        NavigationView{
            VStack{
                Spacer()
                    .frame(height: 40)
                
                Form(){
                    Section(header: Text("Details")){
                        TextField("Enter First Name", text: $employeeFirstname)
                        
                        TextField("Enter Last Name", text: $employeeLastname)
                        
                        TextField("Enter Employee ID Number", text: $employeeNumber.value)
                            .keyboardType(.numberPad)
                        
                        TextField("Input Hourly Wage", text: $employeeWage.value)
                            .keyboardType(.decimalPad)
                        Picker("Select A Department", selection: $employeeDepartment) {
                            ForEach(DeptModel.departments, id: \.self) {
                                Text($0)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add New Employee")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading){
                        
                    Button {
                        self.presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Back")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing){
                    
                    Button {
                        if formIsValid() {
                            EmpModel.createNewEmployee(firstName: employeeFirstname, lastName: employeeLastname, id: employeeNumber, wage: employeeWage, department: employeeDepartment)
                            clearForm()
                        }
                        else {
                            Alert.error("Invalid Entry(s)")
                        }
                    } label: {
                        Text("Submit")
                    }
                }
            }
            
        }
    }
}

struct AddEmployeeView_Previews: PreviewProvider {
    static var previews: some View {
        AddEmployeeView()
    }
}
