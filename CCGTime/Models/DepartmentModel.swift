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
    private var db: Firestore?
    
    @Published var deptStrings = [String]()
    var departments = [Department]()
    
    @Published var archiveStrings = [String]()
    var departmentArray = [Department]()

    var earliestDate: Date = Date()
    
    init(with givenUid: String) {
        db = Firestore.firestore()
        self.uid = givenUid
        self.loadData()
    }
    
    private func loadData() {
        // Add listener for departments collection
        db!.collection("users").document(uid).collection("departments").addSnapshotListener() { (querySnapshot, error) in
            guard error == nil else {
                print("Error adding the snapshot listener \(error!.localizedDescription)")
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
        db!.collection("users").document(uid).collection("archive").addSnapshotListener() { (querySnapshot, error) in
            guard error == nil else {
                print("Error adding the snapshot listener \(error!.localizedDescription)")
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
        
        // Get earliest date
        //earliestDate = await self.getEarliestDate()
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
        self.db!.collection("users")
            .document(uid)
               .collection("departments")
               .document(name)
               .updateData(["deleted" : FirebaseFirestore.Timestamp.init()])
        
        let deptRef = self.db!.collection("users").document(uid).collection("departments").document(name)
        let archiveRef = self.db!.collection("users").document(uid).collection("archive").document(name)

        deptRef.getDocument() { document, err in
            if err != nil { return }
            
            archiveRef.setData(document?.data() ?? ["Document was nil" : ""])
            
        }
        
        let datesRef = deptRef.collection("dates")
        datesRef.getDocuments() { (snapshot, err) in
            if let err = err {
                print(err.localizedDescription)
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
        
        let archiveRef = self.db!.collection("users").document(uid).collection("archive")
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
//            .collection("dates")
//            .document("20220715")
//            .setData([
//                "ontime" : [:],
//                "late" : [:],
//                "tbd" : [:]
//            ])
        
        // Add 'created' field for sorting purposes
        db.collection("users").document(uid).collection("departments")
            .document(departmentName)
            .setData(["created" : FirebaseFirestore.Timestamp.init()])
    }
    
    public func getDates(dept department: String, completion: @escaping (_ dates: [String]) -> Void) {
        
        var dates:[String] = []
        let datesRef = db!.collection("users").document(uid).collection("departments")
                         .document(department)
                         .collection("dates")
        
        datesRef.getDocuments() { (snapshot, err) in
            if let err = err {
                print(err.localizedDescription)
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
        let docRef = db!.collection("users").document(uid).collection("departments")
                       .document(department)
                       .collection("dates")
                       .document(date)
                       .collection("times")

        docRef.getDocuments() { snapshot, error in
            guard error == nil else {
                print("Error adding the snapshot listener \(error!.localizedDescription)")
                return
            }
            
            snapshot!.documents.forEach({ document in
                do {
                    let decodedTimecard = try document.data(as: EmployeeTimecard.self)
                    timecards.append(decodedTimecard)
                }
                catch {
                  print("Error trying to decode Timecard \(error)")
                }
            })
            completion(timecards)
        }
    }
    
    func generateReport(selectedDepartment: String, startDate: Date, endDate: Date) -> Void {
        
        // Ensure start date is before end date
        guard startDate <= endDate else {
            print("Start date must be before or equal to end date")
            return
        }
        
        //getEarliestDate()
        
        // Your report generation logic here
        print("Generating report for \(selectedDepartment) from \(startDate) to \(endDate)")
        
        
    }
    
    // Gets the earliest recorded clock-in date in YYYYMMDD and returns a Date object with the same timestamp.
    // Used in the GenerateReportView sheet
    public func getEarliestDate() async -> Date {
        var earliestInt: Int32 = Int32.max
        
        let departments = db!.collection("users").document(uid).collection("departments")
        
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
                        print("DocumentID: \(item.documentID)")
                        print("DocID Int: \(newInt)")
                        earliestInt = newInt
                        print(earliestInt)
                    }
                }
            }
        }
        
        let earliestDate = self.dateFromInt32(earliestInt)!
        return earliestDate
        
        
    }
    
    // Converts Int32 in "YYYYMMDD" format to a Date object with the same timestamp
    private func dateFromInt32(_ dateInt: Int32) -> Date? {
        let yearInt = dateInt / 10000
        let monthInt = (dateInt % 10000) / 100
        let dayInt = dateInt % 100
        
        var dateComponents = DateComponents()
        dateComponents.year = Int(yearInt)
        dateComponents.month = Int(monthInt)
        dateComponents.day = Int(dayInt)
        
        let calendar = Calendar.current
        return calendar.date(from: dateComponents)
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
    
}
