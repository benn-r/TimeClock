//
//  ManagerialView.swift
//  CCGTime
//
//  Created by ben on 5/25/22.
//

import SwiftUI
import Firebase

struct IdentifiableView: Identifiable {
    let view: AnyView
    let id = UUID()
}

struct ManagerView: View {
    
    @State private var nextView: IdentifiableView? = nil
    @ObservedObject var DeptModel = DepartmentModel()
    
    func generateReport() {
        print("Report Generated")
    }
    
    var body: some View {
        
        NavigationView {

            VStack(alignment: .center) {

                List {
                    Section("Departments") {
                        ForEach(DeptModel.departments, id: \.self) { item in
                            NavigationLink(destination: DepartmentView(dept: item)) {
                                Text(item)
                            }
                        }
                        .onDelete(perform: { indexSet in
                            indexSet.forEach { index in
                                DeptModel.trashDepartment(DeptModel.departments[index])
                            }
                        })
                    }
                }
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
