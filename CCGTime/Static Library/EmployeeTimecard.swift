//  EmployeeTimecard.swift
//  CCGTime
//
//  Created by ben on 7/17/22.
//
//  Each employee should have their own EmployeeTimecard struct
//  for each day they work.

import Foundation
import FirebaseFirestoreSwift
import FirebaseFirestore

struct EmployeeTimecard: Codable, Hashable {
    
    
    @DocumentID var id: String?
    var employeeId: String
    var department: String
    var firstName: String
    var lastName: String
    var name: String
    var wage: Double
    var timecardEvents: [Date]
    var exists: Bool
    
    init(id: String, dept: String, firstName: String, lastName: String, name: String, wage: Double) {
        self.id = id
        self.employeeId = id
        self.department = dept
        self.firstName = firstName
        self.lastName = lastName
        self.name = name
        self.wage = wage
        
        
        self.exists = true
        self.timecardEvents = []
        
    }
    
    /* Required code to make the EmployeeTimecard struct Codable and Hashable */
    
    private enum CodingKeys: String, CodingKey {
        case employeeId
        case department
        case firstName
        case lastName
        case name
        case wage
        case timecardEvents
        case exists
    }
    
    // getID
    // Returns copy of employeeID var for the current timecard
    
    func getId() -> String {
        let id: String = self.employeeId
        return id
    }
    
    // getDept
    // Returns a copy of employeeDept var for the current timecard
    
    func getDept() -> String {
        let dept: String = self.department
        return dept
    }
    
    func numOfEvents() -> Int {
        let events: Int = self.timecardEvents.count
        return events
    }
}
