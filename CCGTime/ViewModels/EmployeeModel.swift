//
//  EmployeeModel.swift
//  CCGTime
//
//  Created by ben on 7/16/22.
//

import Foundation
import FirebaseFirestore

class EmployeeModel: ObservableObject {
    
    /*
     * employeeNames structure - employeeNames[2201] = "Ben Rosario"
     */
    @Published var employees: [String:Employee] = [:]
    let db: Firestore!
    
    init() {
        db = Firestore.firestore()
        self.loadData()
    }
    
    func loadData() {
        // Add listener for employees collection
        db.collection("employees").addSnapshotListener() { (querySnapshot, error) in
            guard error == nil else {
                print("ERROR: adding the snapshot listener \(error!.localizedDescription)")
                return
            }
            
            for document in querySnapshot!.documents {
                let id = document.documentID
                let firstName = document.get("firstName") as! String
                let lastName = document.get("lastName") as! String
                let wage = document.get("wage") as! Double
                let department = document.get("department") as! String
                
                self.employees[id] = Employee(firstName: firstName, lastName: lastName,  wage: wage, department: department)
            }
        }
    }
    
    func getName(id: String) -> String {
        
        let employee = employees[id]
        var fullName: String = ""
        
        if employee != nil {
            let firstName: String = employee!.firstName
            let lastName: String = employee!.lastName
            fullName = "\(firstName) \(lastName) (\(id))"
        }
        else {
            fullName = "Employee \(id)"
        }
        
        return fullName
    }
    
    func fetchTimecards(department: String, completion: @escaping (_ timecard: EmployeeTimecard) -> Void) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let todaysDateString = dateFormatter.string(from: Date.now)
        
        let docRef = db.collection("departments")
                       .document(department)
                       .collection("dates")
                       .document(todaysDateString)
      
        docRef.getDocument(as: EmployeeTimecard.self) { result in
            switch result {
            case .success(let timecard):
                // An EmployeeTimeCard was successfully initialized from the DocumentSnapshot.
                print(timecard)
                completion(timecard)
            case .failure(let error):
                // An EmployeeTimeCard could not be initialized from the DocumentSnapshot.
                print("Error decoding document: \(error.localizedDescription)")
            }
        }
    }
    
    func clockIn(timecard: EmployeeTimecard, department: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let todaysDateString = dateFormatter.string(from: Date.now)
        
        db.collection("departments").document(department).collection("dates").document(todaysDateString).setData(["visible" : true])
        
        let docRef = db.collection("departments")
                       .document(department)
                       .collection("dates")
                       .document(todaysDateString)
                       .collection("times")
                       .document(timecard.id!)
        
        do {
            var timecard = timecard
            timecard.timeIn = Date.now
            
            try docRef.setData(from: timecard)
        }
        catch {
            print("Error when trying to encode EmployeeTimeCard: \(error)")
        }
    }

    func createNewEmployee(firstName: String, lastName: String, id: NumbersOnly, wage: FloatsOnly, department: String) {
        
        let docRef = db.collection("employees").document(id.value)
        
        do {
            let employee = Employee(
                firstName: firstName,
                lastName: lastName,
                wage: Double(wage.value) ?? 0.0,
                department: department
            )
            
            try docRef.setData(from: employee)
        }
        catch {
          print("Error when trying to encode Employee: \(error)")
        }
    }
    
    func checkId(id: NumbersOnly, completion: @escaping (_ idExists: Bool) -> Void) {
        
        if (id.value == "") {
            completion(false)
        }
        else {
            let docRef = db.collection("employees").document(id.value)
            //
            // Firestore Docs example getDocument function
            // https://firebase.google.com/docs/firestore/query-data/get-data#swift
            //
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                    print("Document data: \(dataDescription)")
                    completion(true)
                } else {
                    print("Document does not exist")
                    completion(false)
                }
            }
        }
    }
    
    func get(id: NumbersOnly, completion: @escaping (_ employee: Employee) -> Void) {
        let docRef = db.collection("employees").document(id.value)
        
        docRef.getDocument(as: Employee.self) { result in
            switch result {
            case .success(let employee):
                // An Employee was successfully initialized from the DocumentSnapshot.
                print(employee)
                completion(employee)
            case .failure(let error):
                // An Employee could not be initialized from the DocumentSnapshot.
                print("Error decoding document: \(error.localizedDescription)")
            }
        }
    }
    
//    func createNewEmployee(firstName: String, lastName: String, employeeNumber: NumbersOnly, wage: FloatsOnly, department: String) {
//
//        db.collection("employees").document(employeeNumber.value)
//            .setData([
//                "firstName" : firstName,
//                "lastName" : lastName,
//                "wage" : Double(wage.value)!,
//                "department" : department
//            ])
//
//    }
}
