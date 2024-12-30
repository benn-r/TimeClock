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
import SwiftUI


class DepartmentModel: ObservableObject {
    
    private var uid: String
    private var db: Firestore
    
    var departments = [Department]()
    var departmentArray = [Department]()
    var earliestDate: Date?
    
    @Published var deptStrings = [String]()
    @Published var archiveStrings = [String]()
    
    init(with givenUid: String) {
        db = Firestore.firestore()
        self.uid = givenUid
        self.loadData()
    }
    
    private func loadData() {
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
    
}
