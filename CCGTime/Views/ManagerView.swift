//
//  ManagerialView.swift
//  CCGTime
//
//  Created by Ben Rosario on 5/25/22.
//

import SwiftUI
import Firebase

struct IdentifiableView: Identifiable {
    let view: AnyView
    let id = UUID()
}

struct ManagerView: View {
    
    @State private var showingArchiveAlert = false
    @State private var showingUnarchiveAlert = false
    @State private var showingDeleteAlert = false
    @State private var currentDept: String = ""
    
    @State private var nextView: IdentifiableView? = nil
    @ObservedObject var DeptModel = DepartmentModel()
    @ObservedObject var EmpModel = EmployeeModel()
    
    func generateReport() {
        print("Employees: ")
    }
    
    var body: some View {
        
        NavigationView {

            VStack(alignment: .center) {

                List {
                    // Current Employees
                    Section("Employees") {
                        
                        ForEach(EmpModel.employeeIdStrings, id: \.self) { item in
                            
                            let empName = EmpModel.getName(id: item, withId: false)
                            
                            NavigationLink(destination: EmployeeManagementView(employeeId: item)) {
                                Text(empName)
                            }
                        }
                    }
                    // Current Departments
                    Section("Current Departments") {
                        ForEach(DeptModel.deptStrings, id: \.self) { item in
                            
                            NavigationLink(destination: DepartmentView(dept: item)) {
                                Text(item)
                                    .swipeActions(allowsFullSwipe: false) {
                                        Button("Archive") {
                                            currentDept = item
                                            showingArchiveAlert = true
                                        }
                                    }
                                    .tint(.red)
                            }
                        }
                    }
                    // Archived Departments
                    Section("Archived Departments") {
                        ForEach(DeptModel.archiveStrings, id: \.self) { item in
                            NavigationLink(destination: DepartmentView(dept: item)) {
                                Text(item)
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button("Delete") {
                                            currentDept = item
                                            showingDeleteAlert = true
                                        }
                                        .tint(.red)
                                    }
                                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                        Button("Unarchive") {
                                            currentDept = item
                                            showingUnarchiveAlert = true
                                        }
                                        .tint(.blue)
                                    }
                            }
                        }
                    }
                }
                // Confirmation dialogue for delete button
                .confirmationDialog(
                    "Are you sure you want to delete \'\(currentDept)\'? \nYou cannot undo this action.",
                    isPresented: $showingDeleteAlert,
                    titleVisibility: .visible
                ) {
                    Button("Delete") {
                        withAnimation {
                            DeptModel.deleteDepartment(currentDept)
                        }
                    }
                }
                // Confirmation dialogue for archive button
                .confirmationDialog(
                    "Are you sure you want to archive \'\(currentDept)\'?",
                    isPresented: $showingArchiveAlert,
                    titleVisibility: .visible
                ) {
                    Button("Archive") {
                        withAnimation {
                            DeptModel.archiveDepartment(currentDept)
                        }
                    }
                }
                // Confirmation Dialogue for unarchive button
                .confirmationDialog(
                    "Are you sure you want to unarchive \'\(currentDept)\'?",
                    isPresented: $showingUnarchiveAlert,
                    titleVisibility: .visible
                ) {
                    Button("Unarchive") {
                        withAnimation {
                            DeptModel.unarchiveDepartment(currentDept)
                        }
                    }
                }
                // Code for switching view to employee creation
                .fullScreenCover(item: self.$nextView, onDismiss: { nextView = nil }) { view in
                    view.view
                }
                
                
                
            }
                
            .navigationTitle("Management")
            .toolbar {
                ToolbarItemGroup() {
                    Menu("Options") {
                        
                        Button {
                            Alert.newDept()
                        } label: {
                            Label("Create New Department", systemImage: "note.text.badge.plus")
                        }
                                    
                        Button {
                            generateReport()
                        } label: {
                            Label("Generate Report", systemImage: "tablecells")
                        }
                        
                        Button {
                            self.nextView = IdentifiableView(view: AnyView(AddEmployeeView()))
                        } label: {
                            Label("Add New Employee", systemImage: "person.badge.plus")
                        }
                        
                        Button {
                            self.nextView = IdentifiableView(view: AnyView(AccountView()))
                        } label: {
                            Label("Account Settings", systemImage: "gearshape.fill")
                        }
                        
                    }
                }
            }
        }
    }
}

struct ManagerialView_Previews: PreviewProvider {
    static var previews: some View {
        ManagerView()
    }
}
