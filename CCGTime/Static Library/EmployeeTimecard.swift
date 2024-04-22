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
    var employeeID: String
    var employeeDept: String
    var timecardEvents: [Date]
    var exists: Bool
    
    init(id: String, dept: String) {
        self.employeeID = id
        self.employeeDept = dept
        
        self.exists = true
        self.timecardEvents = []
        
        // ID variable is for FireStore storing and labeling purposes, same as employeeID
        self.id = employeeID
    }
    
    /* Required code to make the EmployeeTimecard struct Codable and Hashable */
    
    private enum CodingKeys: String, CodingKey {
        case employeeID
        case employeeDept
        case timecardEvents
        case exists
    }
    
    // getID
    // Returns copy of employeeID var for the current timecard
    
    func getID() -> String {
        let id: String = self.employeeID
        return id
    }
    
    // getDept
    // Returns a copy of employeeDept var for the current timecard
    
    func getDept() -> String {
        let dept: String = self.employeeDept
        return dept
    }
    
    func numOfEvents() -> Int {
        let events: Int = self.timecardEvents.count
        return events
    }
}
