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
    @Published var employeeNameStrings: [String] = []
    @Published var employeeIdStrings: [String] = []
    
    fileprivate let db: Firestore!
    
    let staticDate: Date = Date.init(timeIntervalSince1970: TimeInterval(0))
    var lastTimeClocked: Date = Date.init(timeIntervalSince1970: TimeInterval(0))
    var lastIdClocked: String = ""
    
    init() {
        db = Firestore.firestore()
        self.loadData()
    }
    
    private func loadData() {
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
                
                
                let fullName = "\(firstName) \(lastName)"
                self.employeeNameStrings.append(fullName)
                
                self.employeeIdStrings.append(id)
                
                self.employees[id] = Employee(firstName: firstName, lastName: lastName,  wage: wage, department: department)
            }
        }
    }
    
    func getDept(id: NumbersOnly) -> String {
        let empId = id.value
        let employee = employees[empId]
        let empDept: String = employee!.department
        
        return empDept
    }
    
    func getName(id: String, withId: Bool) -> String {
        
        let employee = employees[id]
        var fullName: String = ""
        
        if employee != nil {
            let firstName: String = employee!.firstName
            let lastName: String = employee!.lastName
            
            if (withId) {
                fullName = "\(firstName) \(lastName) (\(id))"
            }
            else {
                fullName = "\(firstName) \(lastName)"
            }
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
                completion(timecard)
            case .failure(let error):
                // An EmployeeTimeCard could not be initialized from the DocumentSnapshot.
                print("Error decoding document: \(error.localizedDescription)")
            }
        }
    }
    
    /**
            Checks if the given person with the given ID and Department is clocked in on the current day
     */
    func isClockedIn(id: String, dept: String, completion: @escaping (Bool) -> Void) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let todaysDateString = dateFormatter.string(from: Date.now)
        
        let timecardRef = db.collection("departments").document(dept).collection("dates").document(todaysDateString).collection("times").document(id)
        
        
            
        timecardRef.getDocument(as: EmployeeTimecard.self) { result in
            switch result {
            case .success(let timecard):
                // Now, we need to check and see if the employee is clocked in
                if ((timecard.timecardEvents.count) % 2 == 0) {
                    completion(false)
                }
                else if ((timecard.timecardEvents.count) % 2 == 1) {
                    completion(true)
                }
            case .failure(let error):
                // An EmployeeTimeCard could not be initialized from the DocumentSnapshot.
                print("Error decoding document: \(error.localizedDescription)")
                // For now, assume employee is not clocked in
                completion(false)
                
            }
        }
    }
    
    /*
     As of now, func clockIn() will assume that the employee has already clocked out,
     and will always generate a timeIn stamp 
     That means it is important to check that the employee has already clocked out
     before you call this function!
     */
    func clockIn(id: String, department: String) {
        
        if (lastTimeClocked == staticDate && lastIdClocked == "" ) {
            lastTimeClocked = Date.init()
            lastIdClocked = id
        }
        else if (lastIdClocked != id) {
            let elapsed = Date.now.timeIntervalSince(lastTimeClocked)
            let duration = Int(elapsed)
            
            if (duration < 10) {
                Alert.message("Error", "Too many attempts. Please try again in a moment.")
                return
            }
            
        }
        else {
            let elapsed = Date.now.timeIntervalSince(lastTimeClocked)
            let duration = Int(elapsed)
            
            if (duration < 61) {
                let cooldownTime = String(61 - duration)
                Alert.message("Error", "ID \(id) has recently clocked out.\nPlease wait \(cooldownTime) seconds to clock in.")
                return
            }
            
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let todaysDateString = dateFormatter.string(from: Date.now)
        
        db.collection("departments").document(department).collection("dates").document(todaysDateString).setData(["visible" : true])
        
        let timecardDocRef = db.collection("departments").document(department).collection("dates").document(todaysDateString).collection("times").document(id)
        
        timecardDocRef.getDocument(as: EmployeeTimecard.self) { result in
            switch result {
                
            case .success(let timecard):
                if (timecard.exists) {
                    print("Timecard already exists")
                    timecardDocRef.updateData([
                        "timecardEvents" : FieldValue.arrayUnion([Date.now])
                    ])
                } else {
                    // This path might never be reached? describing as fatal error
                    print("FATAL ERROR: timecard was instantiated but the exists attribute is false?")
                }
                
            case .failure(let error):
                print("Expected Error: \(error)")
                // This will ALWAYS have a failure case if the document does not exist yet
                print("Timecard doesn't exist, creating one now...")
                // Create new timecard and set data in Firebase
                let newTimecard: EmployeeTimecard = EmployeeTimecard(id: id, dept: department)
                
                do {
                    try timecardDocRef.setData(from: newTimecard)
                    print("Set data from newTimecard")
                } catch {
                    print("Error occurred while trying to clock in: \(error)")
                }
                
                // Update new timecard with clock in data (should be the first time event in the timecard)
                timecardDocRef.updateData([
                    "timecardEvents" : FieldValue.arrayUnion([Date.now])
                ])
                print("Updated timecard with clock in info")
                
            } // end switch case
            
        }
    }
    
    /*
     As of now, func clockOut() will assume that the employee has already clocked in,
     and will always generate a timeOut stamp
     That means it is important to check that the employee has already clocked in
     before you call this function!
     */
    func clockOut(id: String, department: String) {
        
        if (lastTimeClocked == staticDate && lastIdClocked == "" ) {
            lastTimeClocked = Date.init()
            lastIdClocked = id
        }
        else if (lastIdClocked != id) {
            let elapsed = Date.now.timeIntervalSince(lastTimeClocked)
            let duration = Int(elapsed)
            
            if (duration < 10) {
                Alert.message("Error", "Too many attempts. Please try again in a moment.")
                return
            }
            
        }
        else {
            
            let elapsed = Date.now.timeIntervalSince(lastTimeClocked)
            let duration = Int(elapsed)
            if (duration < 61) {
                let cooldownTime = String(61 - duration)
                Alert.message("Error", "ID \(id) has recently clocked in.\nPlease wait \(cooldownTime) seconds to clock out.")
                return
            }
            
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let todaysDateString = dateFormatter.string(from: Date.now)
        
        db.collection("departments").document(department).collection("dates").document(todaysDateString).setData(["visible" : true])
        
        let timecardDocRef = db.collection("departments")
                       .document(department)
                       .collection("dates")
                       .document(todaysDateString)
                       .collection("times")
                       .document(id)
        
        do {
            
            timecardDocRef.updateData([
                "timecardEvents" : FieldValue.arrayUnion([Date.now])
            ])
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
        
        var idIsValid: Bool = false;

        if (id.value == "") {
            idIsValid = false
            completion(idIsValid)
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
                    idIsValid = true
                    completion(idIsValid)
                } else {
                    print("Document does not exist")
                    idIsValid = false
                    completion(idIsValid)
                }
            }
        }
    }
    /**
    * Make sure to call checkId on the same id number BEFORE calling the get function
    * A failure case may occur otherwise
    * This is because the id you are trying to get may not exist
    */
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
