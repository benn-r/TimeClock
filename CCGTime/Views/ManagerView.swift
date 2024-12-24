//
//  ManagerView.swift
//  CCGTime
//
//  Created by Ben Rosario on 5/25/22.
//

import SwiftUI
import Firebase
import LocalAuthentication

struct ManagerView: View {
    
    @EnvironmentObject var user: SessionStore
    @EnvironmentObject var departmentModel: DepartmentModel
    @EnvironmentObject var employeeModel: EmployeeModel
    
    @State private var showingArchiveAlert = false
    @State private var showingUnarchiveAlert = false
    @State private var showingDeleteAlert = false
    @State private var currentDept: String = ""
    @State private var newDeptName: String = ""
    
    @State private var showGenerateReportSheet = false
    @State private var showAddNewEmployeeSheet = false
    @State private var showAccountSettingsSheet = false
    @State private var showCreateDeptAlert = false
    
    @State private var selectedStartDate = Date()
    @State private var selectedEndDate = Date()
    @State private var selectedDepartment: String = ""
    
    @StateObject  var authModel = AuthModel()
    
    var body: some View {
        
        NavigationView {
            
            // Has to be inside the navigation view, otherwise the entire ViewController refreshes
            
            if authModel.isUnlocked == false {
                Button("Unlock Manager View", action: authModel.authenticate)
                    .padding()
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(.capsule)
            } else {
                
                VStack(alignment: .center) {
                    
                    List {
                        employeeSection
                        currentDepartmentsSection
                        archivedDepartmentsSection
                    }
                    
                    // Confirmation dialogue for delete button
                    .confirmationDialog(
                        "Are you sure you want to delete \'\(currentDept)\'? \nYou cannot undo this action.",
                        isPresented: $showingDeleteAlert,
                        titleVisibility: .visible
                    ) {
                        Button("Delete") {
                            withAnimation {
                                departmentModel.deleteDepartment(currentDept)
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
                                departmentModel.archiveDepartment(currentDept)
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
                                departmentModel.unarchiveDepartment(currentDept)
                            }
                        }
                    }
                }
                .alert(Text("Create New Department"), isPresented: $showCreateDeptAlert) {
                    TextField("New Department Name", text: $newDeptName)
                    Button("Cancel", role: .cancel) {
                        showCreateDeptAlert = false
                    }
                    Button("Create") {
                        
                        if newDeptName != "" {
                            departmentModel.createDepartment(newDeptName)
                            showCreateDeptAlert = false
                        } else {
                            Alert.message("Error", "Please enter a department name")
                            showCreateDeptAlert = false
                        }
                        
                        
                    }
                } message: { Text("Enter New Department Name") }
                // Grabs value for GenerateReportView
                .onAppear {
                    departmentModel.getEarliestDate()
                }
                // Sheet for Generate Report button
                .sheet(isPresented: $showGenerateReportSheet) {
                    GenerateReportView(
                        showGenerateReportAlert: $showGenerateReportSheet,
                        startDate: $selectedStartDate,
                        endDate: $selectedEndDate,
                        selectedDepartment: $selectedDepartment,
                        earliestDate: departmentModel.earliestDate!
                    )
                }
                .sheet(isPresented: $showAddNewEmployeeSheet) {
                    AddEmployeeView(
                        showAddNewEmployeeSheet: $showAddNewEmployeeSheet
                    )
                }
                .sheet(isPresented: $showAccountSettingsSheet) {
                    AccountView(
                        showAccountSettingsSheet: $showAccountSettingsSheet
                    )
                }
                .navigationTitle("Management")
                .toolbar {
                    ToolbarItemGroup() {
                        Menu("Options") {
                            Button("Create New Department", systemImage: "note.text.badge.plus") { showCreateDeptAlert = true }
                            Button("Generate Report", systemImage: "tablecells") { showGenerateReportSheet = true }
                            Button("Add New Employee", systemImage: "person.badge.plus") { showAddNewEmployeeSheet = true }
                            Button("Account Settings", systemImage: "gearshape.fill") { showAccountSettingsSheet = true }
                        }
                    }
                }
            }
        }
        .onDisappear(perform: authModel.lock)
    }
    
    var employeeSection: some View {
        Section("Employees") {
            
            ForEach(employeeModel.idStrings, id: \.self) { id in
                
                let empName = employeeModel.getName(get: id)
                NavigationLink(destination: EmployeeManagementView(for: id)) {
                    Text(empName)
                }
            }
        }
    }
    
    var currentDepartmentsSection: some View {
        Section("Current Departments") {
            ForEach(departmentModel.deptStrings, id: \.self) { item in
                
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
    }
    
    var archivedDepartmentsSection: some View {
        Section("Archived Departments") {
            ForEach(departmentModel.archiveStrings, id: \.self) { item in
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
    
}

struct ManagerView_Previews: PreviewProvider {
    static var previews: some View {
        ManagerView()
    }
}
