//
//  ManagerView.swift
//  CCGTime
//
//  Created by Ben Rosario on 5/25/22.
//

import SwiftUI
import Firebase
import LocalAuthentication

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
    @ObservedObject private var deptModel: DepartmentModel
    @ObservedObject private var empModel : EmployeeModel
    @ObservedObject private var session : SessionStore
    @StateObject private var authModel = AuthModel()
    
    @State private var showGenerateReportAlert = false
    @State private var selectedStartDate = Date()
    @State private var selectedEndDate = Date()
    @State private var selectedDepartment: String = ""
    
    
    init(session: SessionStore) {
        self.session = session
        //self.authModel = authModel
        empModel = EmployeeModel(session: session)
        deptModel = DepartmentModel(session: session)
    }
    
    var body: some View {
        
        NavigationView {
            
            // Has to be inside the navigation view, otherwise the entire ViewController refreshes
            
            if authModel.isUnlocked == true {
                
                VStack(alignment: .center) {
                    
                    List {
                        // Current Employees
                        Section("Employees") {
                            
                            ForEach(empModel.employeeIdStrings, id: \.self) { item in
                                
                                let empName = empModel.getName(id: item, withId: false)
                                
                                NavigationLink(destination: EmployeeManagementView(session: session, employeeId: item)) {
                                    Text(empName)
                                }
                            }
                        }
                        // Current Departments
                        Section("Current Departments") {
                            ForEach(deptModel.deptStrings, id: \.self) { item in
                                
                                NavigationLink(destination: DepartmentView(session: session, dept: item)) {
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
                            ForEach(deptModel.archiveStrings, id: \.self) { item in
                                NavigationLink(destination: DepartmentView(session: session, dept: item)) {
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
                                deptModel.deleteDepartment(currentDept)
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
                                deptModel.archiveDepartment(currentDept)
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
                                deptModel.unarchiveDepartment(currentDept)
                            }
                        }
                    }
                    // Code for switching view to employee creation
                    .fullScreenCover(item: self.$nextView, onDismiss: { nextView = nil }) { view in
                        view.view
                    }
                }
                // Sheet for Generate Report button
                .sheet(isPresented: $showGenerateReportAlert) {
                    GenerateReportView(
                        showGenerateReportAlert: $showGenerateReportAlert,
                        selectedStartDate: $selectedStartDate,
                        selectedEndDate: $selectedEndDate,
                        selectedDepartment: $selectedDepartment,
                        deptModel: deptModel
                    )
                }
                    
                .navigationTitle("Management")
                .toolbar {
                    ToolbarItemGroup() {
                        Menu("Options") {
                            
                            // Create New Department button
                            Button("Create New Department", systemImage: "note.text.badge.plus") {
                                Alert.newDept(session: session)
                            }
                                        
                            // Generate Report button
                            Button("Generate Report", systemImage: "tablecells") {
                                showGenerateReportAlert = true
                                
                                print("showDateSelectAlert: \(showGenerateReportAlert)")
                                print("currentDepts: \(deptModel.deptStrings)")
                            }
                            
                            // Add New Employee button
                            Button("Add New Employee", systemImage: "person.badge.plus") {
                                self.nextView = IdentifiableView(view: AnyView(AddEmployeeView(session: session)))
                            }
                            
                            // Account Settings button
                            Button("Account Settings", systemImage: "gearshape.fill") {
                                self.nextView = IdentifiableView(view: AnyView(AccountView(session: session)))
                            }
                            
                        }
                    }
                }

                
            } else {
                Button("Unlock Manager View", action: authModel.authenticate)
                    .padding()
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(.capsule)
            }

        }
        .onDisappear(perform: authModel.lock)
    }
}

struct ManagerView_Previews: PreviewProvider {
    static var previews: some View {
        ManagerView(session: SessionStore())
    }
}
