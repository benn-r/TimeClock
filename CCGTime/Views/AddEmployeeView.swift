//
//  AddEmployeeView.swift
//  CCGTime
//
//  Created by ben on 5/25/22.
//

import SwiftUI

struct AddEmployeeView: View {
    
    var session: SessionStore
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State fileprivate var creationSuccessAlert = false
    @State fileprivate var creationFailureAlert = false
    
    @State fileprivate var selectedDepartment = "Select A Department"

    @State fileprivate var employeeFirstname = ""
    @State fileprivate var employeeLastname = ""
    @State fileprivate var employeeDepartment = ""
    @ObservedObject fileprivate var employeeNumber = NumbersOnly()
    @ObservedObject fileprivate var employeeWage = FloatsOnly()
    @ObservedObject fileprivate var DeptModel : DepartmentModel
    
    @ObservedObject fileprivate var EmpModel : EmployeeModel
    
    init(session: SessionStore) {
        self.session = session
        EmpModel = EmployeeModel(session: session)
        DeptModel = DepartmentModel(session: session)
    }
    
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
                        
                        Menu(selectedDepartment) {
                            ForEach(DeptModel.deptStrings, id: \.self) { item in
                                Button(item) {
                                    self.selectedDepartment = item
                                    self.employeeDepartment = item
                                }
                            }
                        }
                    }
                }
                .alert("Success!", isPresented: $creationSuccessAlert) {
                    // buttons
                } message: {
                    Text("Employee was added.")
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
                            EmpModel.createNewEmployee(session: session, firstName: employeeFirstname, lastName: employeeLastname, id: employeeNumber, wage: employeeWage, department: employeeDepartment)
                            
                            creationSuccessAlert = true
                            
                            clearForm()
                        }
                        else {
                            // TODO: (?) Display exactly which entries are invalid using a for loop
                            creationFailureAlert = true
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
        AddEmployeeView(session: SessionStore())
    }
}
