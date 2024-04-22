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
    
    @Published var deptStrings = [String]()
    var departments = [Department]()
    
    @Published var archiveStrings = [String]()
    var archives = [Department]()
    
    fileprivate var db: Firestore!
    
    init() {
        db = Firestore.firestore()
        self.loadData()
    }
    
    fileprivate func loadData() {
        // Add listener for departments collection
        db.collection("departments").addSnapshotListener() { (querySnapshot, error) in
            guard error == nil else {
                print("ERROR: adding the snapshot listener \(error!.localizedDescription)")
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
        db.collection("archive").addSnapshotListener() { (querySnapshot, error) in
            guard error == nil else {
                print("ERROR: adding the snapshot listener \(error!.localizedDescription)")
                return
            }
            self.archives = []
            self.archiveStrings = []
            
            // there are querySnapshot!.documents.count documents in the spots snapshot
            for document in querySnapshot!.documents {
                let dept = Department(name: document.documentID)
                self.archives.append(dept)
                self.archiveStrings.append(dept.name)
            }
        }
    }
    
    func simpleDate(_ date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let newDate: Date = dateFormatter.date(from: date) ?? Date.distantPast
        
        dateFormatter.dateFormat = "MMM d, yyyy"
        let simpleDateString: String = dateFormatter.string(from: newDate)
        
        return simpleDateString
    }
    
    func fancyDate(_ date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let newDate: Date = dateFormatter.date(from: date) ?? Date.distantPast
        
        dateFormatter.dateFormat = "EEEE, MMMM d, yyyy"
        let fancyDateString: String = dateFormatter.string(from: newDate)
        
        return fancyDateString
    }
    
    func archiveDepartment(_ name: String) {
        
        print("Archiving Department: \(name)")
        
        // Add 'deleted' field for sorting purposes
        self.db.collection("departments")
            .document(name)
            .updateData(["deleted" : FirebaseFirestore.Timestamp.init()])
        
        let deptRef = self.db.collection("departments").document(name)
        let archiveRef = self.db.collection("archive").document(name)

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
                archiveRef.collection("dates").document(docID).setData(data)
            })
        }
        deptRef.delete()
    }
    
    func unarchiveDepartment(_ name: String) {
        //TODO: Create function
        print("Unarchiving department: \(name)")
    }
    
    func deleteDepartment(_ name: String) {
        
        let archiveRef = self.db.collection("archive")
        let docRef = archiveRef.document(name)
        
        /*
            TODO: Delete subcollections from Firestore via
            server or cloud function - doing so from a mobile
            client has negative security and performance implications
         */
        
        docRef.delete()
        //     ^ DOES NOT delete subcollections
        
    }
    
    func createDepartment(_ departmentName: String) {
        // Get reference to the database
        let db = Firestore.firestore()
        
        // Add document to collection
        db.collection("departments")
            .document(departmentName)
//            .collection("dates")
//            .document("20220715")
//            .setData([
//                "ontime" : [:],
//                "late" : [:],
//                "tbd" : [:]
//            ])
        
        // Add 'created' field for sorting purposes
        db.collection("departments")
            .document(departmentName)
            .setData(["created" : FirebaseFirestore.Timestamp.init()])
    }
    
    func getDates(dept department: String, completion: @escaping (_ dates: [String]) -> Void) {
        
        var dates:[String] = []
        let datesRef = db.collection("departments")
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
    
    func getTimes(dept department: String, date: String, completion: @escaping (_ timecard: [EmployeeTimecard]) -> Void) {

        var timecards: [EmployeeTimecard] = []
        let docRef = db.collection("departments")
                       .document(department)
                       .collection("dates")
                       .document(date)
                       .collection("times")

        docRef.getDocuments() { snapshot, error in
            guard error == nil else {
                print("ERROR: adding the snapshot listener \(error!.localizedDescription)")
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
}
