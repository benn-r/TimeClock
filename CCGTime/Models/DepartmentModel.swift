//
//  DepartmentModel.swift
//  CCGTime
//
//  Created by Ben Rosario on 5/26/22.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import OrderedCollections

class DepartmentModel: ObservableObject {
    
    private var uid: String
    private var db: Firestore
    
    var departments = [Department]()
    var departmentArray = [Department]()
    var allEmployees = [String:Employee]()
    var earliestDate: Date?
    
    @Published var deptStrings = [String]()
    @Published var archiveStrings = [String]()
    @Published var reportLoading: Bool = false
    @Published var report: Report?
    
    init(with givenUid: String) async {
        db = Firestore.firestore()
        self.uid = givenUid
        await self.loadData()
    }
    
    private func loadData() async {
        // Add listener for departments collection
        db.collection("users").document(uid).collection("departments").addSnapshotListener() { (querySnapshot, error) in
            guard error == nil else {
                print("Error adding the snapshot listener: \(error!.localizedDescription)")
                return
            }
            self.departments = []
            self.deptStrings = []
            // there are querySnapshot!.documents.count documents in the spots snapshot
            for document in querySnapshot!.documents {
                let dept = Department(name: document.documentID)
                self.departments.append(dept)
                self.deptStrings.append(dept.name)
            }
        }
        
        // Add listener for archive collection
        db.collection("users").document(uid).collection("archive").addSnapshotListener() { (querySnapshot, error) in
            guard error == nil else {
                print("Error adding the snapshot listener: \(error!.localizedDescription)")
                return
            }
            self.departmentArray = []
            self.archiveStrings = []
            
            // there are querySnapshot!.documents.count documents in the spots snapshot
            for document in querySnapshot!.documents {
                let dept = Department(name: document.documentID)
                self.departmentArray.append(dept)
                self.archiveStrings.append(dept.name)
            }
        }
        
        
        do {
            let employees = try await db.collection("users").document(uid).collection("employees").getDocuments()
            
            
            for employee in employees.documents {
                let firstName = employee.get("firstName") as! String
                let lastName = employee.get("lastName") as! String
                let wage = employee.get("wage") as! Double
                let department = employee.get("department") as! String
                let id = employee.documentID
                
                let newEmployee = Employee(firstName: firstName, lastName: lastName, wage: wage, department: department, employeeId: id)
                
                self.allEmployees[id] = newEmployee
            }
            
        } catch (let error){
            print("Error Creating DepartmentModel allEmployees Array: \(error)")
        }
    }
    
    public func simpleDate(_ date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let newDate: Date = dateFormatter.date(from: date) ?? Date.distantPast
        
        dateFormatter.dateFormat = "MMM d, yyyy"
        let simpleDateString: String = dateFormatter.string(from: newDate)
        
        return simpleDateString
    }
    
    public func fancyDate(_ date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let newDate: Date = dateFormatter.date(from: date) ?? Date.distantPast
        
        dateFormatter.dateFormat = "EEEE, MMMM d, yyyy"
        let fancyDateString: String = dateFormatter.string(from: newDate)
        
        return fancyDateString
    }
    
    public func archiveDepartment(_ name: String) {
        
        print("Archiving Department: \(name)")
        
        // Add 'deleted' field for sorting purposes
        self.db.collection("users")
            .document(uid)
               .collection("departments")
               .document(name)
               .updateData(["deleted" : FirebaseFirestore.Timestamp.init()])
        
        let deptRef = self.db.collection("users").document(uid).collection("departments").document(name)
        let archiveRef = self.db.collection("users").document(uid).collection("archive").document(name)

        deptRef.getDocument() { document, err in
            if err != nil { return }
            
            archiveRef.setData(document?.data() ?? ["Document was nil" : ""])
            
        }
        
        let datesRef = deptRef.collection("dates")
        datesRef.getDocuments() { (snapshot, err) in
            if let err = err {
                print("Error getting documents: \(err.localizedDescription)")
                return
            }

            guard let snapshot = snapshot else { return }

            snapshot.documents.forEach({ (document) in
                let data = document.data()
                let docID = document.documentID
                archiveRef.collection("users").document(self.uid).collection("dates").document(docID).setData(data)
            })
        }
        deptRef.delete()
    }
    
    public func unarchiveDepartment(_ name: String) {
        //TODO: Create function
        print("Unarchiving department: \(name)")
    }
    
    public func deleteDepartment(_ name: String) {
        
        let archiveRef = self.db.collection("users").document(uid).collection("archive")
        let docRef = archiveRef.document(name)
        
        /*
            TODO: Delete subcollections from Firestore via
            server or cloud function - doing so from a mobile
            client has negative security and performance implications
         */
        
        docRef.delete()
        //     ^ DOES NOT delete subcollections
        
    }
    
    public func createDepartment(_ departmentName: String) {
        // Get reference to the database
        let db = Firestore.firestore()
        
        // Add document to collection
        db.collection("users").document(uid).collection("departments")
            .document(departmentName)
        
        // Add 'created' field for sorting purposes
        db.collection("users").document(uid).collection("departments")
            .document(departmentName)
            .setData(["created" : FirebaseFirestore.Timestamp.init()])
    }
    
    public func getDates(dept department: String, completion: @escaping (_ dates: [String]) -> Void) {
        
        var dates:[String] = []
        let datesRef = db.collection("users").document(uid).collection("departments")
                         .document(department)
                         .collection("dates")
        
        datesRef.getDocuments() { (snapshot, err) in
            if let err = err {
                print("Error getting documents: \(err.localizedDescription)")
                return
            }

            guard let snapshot = snapshot else { return }

            snapshot.documents.forEach({ (document) in
                let docID = document.documentID
                dates.append(docID)
            })
            completion(dates)
        }
    }
    
    public func getTimes(dept department: String, date: String, completion: @escaping (_ timecard: [EmployeeTimecard]) -> Void) {

        var timecards: [EmployeeTimecard] = []
        let docRef = db.collection("users").document(uid).collection("departments")
                       .document(department)
                       .collection("dates")
                       .document(date)
                       .collection("times")

        docRef.getDocuments() { snapshot, error in
            guard error == nil else {
                print("Error adding the snapshot listener:  \(error!.localizedDescription)")
                return
            }
            
            snapshot!.documents.forEach({ document in
                do {
                    let decodedTimecard = try document.data(as: EmployeeTimecard.self)
                    timecards.append(decodedTimecard)
                }
                catch {
                  print("Error trying to decode Timecard: \(error)")
                }
            })
            completion(timecards)
        }
    }
    
    // Gets the earliest recorded clock-in date in YYYYMMDD and returns a Date object with the same timestamp.
    // Used in the GenerateReportView sheet
    public func getEarliestDate() {
        
        var earliestInt: Int32 = Int32.max
        var deptsChecked = 0
        
        let departments = db.collection("users").document(uid).collection("departments")
        
        for dept in self.deptStrings {
            
            
            
            let selectedDept = departments.document(dept).collection("dates")
            
            selectedDept.getDocuments { snapshot, error in
                guard error == nil else {
                    print("Error adding the snapshot listener \(error!.localizedDescription)")
                    return
                }
                
                snapshot!.documents.forEach { item in
                    let newInt = Int32(item.documentID)!
                    
                    if newInt < earliestInt {
                        earliestInt = newInt
                        print("Earliest found date: \(earliestInt)")
                    }
                }
                
                deptsChecked += 1
                
                if deptsChecked == self.deptStrings.count {
                    let earliestDate = self.dateFromInt32(earliestInt)!
                    self.earliestDate = earliestDate
                }
            }
                
            }
    }
    
    // Overloads the getEarliestDate function to find the earliest date of a specific department
    // Also returns a date object set to that specific date
    public func getEarliestDate(for dept: String) -> Date {
        
        var earliestInt: Int32 = Int32.max
        
        let deptDates = db.collection("users")
                          .document(uid)
                          .collection("departments")
                          .document(dept)
                          .collection("dates")
            
        deptDates.getDocuments { snapshot, error in
            guard error == nil else {
                print("Error adding the snapshot listener \(error!.localizedDescription)")
                return
            }
            
            snapshot!.documents.forEach { item in
                let newInt = Int32(item.documentID)!
                
                if newInt < earliestInt {
                    earliestInt = newInt
                }
            }
        }
        return self.dateFromInt32(earliestInt)!
    }
    
    // Converts Int32 in "YYYYMMDD" format to a Date object with the same timestamp
    private func dateFromInt32(_ dateInt: Int32) -> Date? {
        let intString = String(dateInt) // Convert Int32 to String
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd" // Match the format
        return dateFormatter.date(from: intString)
    }

    // Converts Date Object to an Int32 in the "YYYYMMDD" format
    private func int32FromDate(_ date: Date) -> Int32 {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        
        let year = components.year ?? 0
        let month = components.month ?? 0
        let day = components.day ?? 0
        
        return Int32(year * 10000 + month * 100 + day)
    }
    
    private func stringFromDate(_ date: Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd" 
        return dateFormatter.string(from: date)
    }
    
    // Returns an array of type Employee for any employee that has worked from the date given
    // until the next sunday (range is only 1 day if the date provided is sunday)
    public func getEmployeesWorkedForWeek(week startingDate: Date, for dept: String) async -> [Employee] {
        
        // dayOfWeek returns 1 for a monday and 7 for a sunday
        var dayOfWeek: Int = startingDate.dayNumberOfWeek()!
        let range = dayOfWeek...7
        
        var employeesWorkedThisWeek: [[Employee]] = []
        var date = startingDate
        
        for _ in range {
            
            let employeesWorked = await self.getEmployeesWorkedForDay(day: date, for: dept)
            employeesWorkedThisWeek.append(employeesWorked)
            
            if let newDate = Calendar.current.date(byAdding: .day, value: 1, to: date) {
                date = newDate
                dayOfWeek += 1
            }
        }
        
        if employeesWorkedThisWeek.isEmpty { return []}
        
        // Remove duplicates
        var employeesWorked: [Employee] = []
        
        for employeeList in employeesWorkedThisWeek {
            for employee in employeeList {
                if !employeesWorked.contains(employee) {
                    print("new employee added to final: \(employee)")
                    employeesWorked.append(employee)
                } else {
                    print("Found Duplicate")
                }
            }
        }
        return employeesWorked
        
    }
    
    // Returns an array with the Employee IDs who worked on the given date
    public func getEmployeesWorkedForDay(day startingDate: Date, for dept: String) async -> [Employee] {
        let employeesRef = db.collection("users")
                         .document(uid)
                         .collection("departments")
                         .document(dept)
                         .collection("dates")
                         .document(self.stringFromDate(startingDate))
                         .collection("times")
        
        var empStrings: [String] = []
        var employees: [Employee] = []
        
        do {
            let querySnapshot = try await employeesRef.getDocuments()
            for emp in querySnapshot.documents {
                let empData = emp.data()
                
                let newEmployee = Employee(firstName: empData["firstName"] as! String,
                                           lastName: empData["lastName"] as! String,
                                           wage: empData["wage"] as! Double,
                                           department: empData["department"] as! String,
                                           employeeId: empData["employeeId"] as! String
                                          )
                
                if !empStrings.contains(newEmployee.employeeId) {
                    employees.append(newEmployee)
                    empStrings.append(newEmployee.employeeId)
                }
            }
        } catch {
          print("Error getting documents: \(error)")
        }
        
        return employees
    }
    
    public func createReport(start startDate: Date, end endDate: Date, for dept: String, name: String) async -> Void {
        Task {
            self.report = await Report(start: startDate, end: endDate, for: dept, name: name, deptModel: self)
        }
    }
    
    public func reportIsCompleted() -> Bool {
        if self.report == nil {
            return false
        } else {
            return report!.completed
        }
    }
    
    public func getName(_ id: String) -> String {
        let employee = allEmployees[id]
        if employee == nil {
            return "No Name Assigned to #\(id)"
        }
        
        let firstName: String = employee!.firstName
        let lastName: String = employee!.lastName
        
        return "\(firstName) \(lastName)"
    }
    
    public func getEmployee(_ id: String) -> Employee? {
        return allEmployees[id]
    }
    
    public func hoursWorked(for emp: Employee, on date: Date) async -> Double {
        let dateString = String(self.int32FromDate(date))
        
        var timeWorked: Double = 0.0
        
        do {
            let dateRef = db.collection("users")
                            .document(uid)
                            .collection("departments")
                            .document(emp.department)
                            .collection("dates")
                            .document(dateString)
                            .collection("times")
            let dateDocument = try await dateRef.document(emp.employeeId).getDocument()
            let timecard = try dateDocument.data(as: EmployeeTimecard.self)
            
            var clockedIn: Date = timecard.timecardEvents[0]
            var clockedOut: Date = timecard.timecardEvents[1]
            
            var i = 0
            for event in timecard.timecardEvents {
                
                
                // Check if this is a clock-in event
                if i%2 == 0 {
                    // If so, then mark beginning
                    clockedIn = event
                } else {
                    // If this is a clock-out event, find the time difference and add it to timeWorked
                    clockedOut = event
                    
                    let timeIntervalInSeconds = clockedOut.timeIntervalSince(clockedIn)
                    let timeIntervalInMins: Double = Double(timeIntervalInSeconds) / 60.0
                    let timeIntervalInHours: Double = timeIntervalInMins / 60.0
                    timeWorked += Double(round(100*timeIntervalInHours)/100)
                }
                i+=1
            }
            return timeWorked
            
            
        } catch (let error) {
            print("hrsWorked Error: \(error.localizedDescription)")
            return 0.0
        }
         
    }
}
