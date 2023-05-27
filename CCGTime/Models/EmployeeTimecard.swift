//
//  EmployeeTimecard.swift
//  CCGTime
//
//  Created by ben on 7/17/22.
//
//  Each employee should have their own EmployeeTimecard struct
//  for each shift they work, every day they work.
//
//  Rework may be need in future, as this solution is likely memory-intensive
//  and hard to work with generally, as you need to find the relevant timecard
//  for each shift.

import Foundation
import FirebaseFirestoreSwift
import FirebaseFirestore

struct EmployeeTimecard: Codable, Hashable {
    
    
    @DocumentID var id: String?
    var employeeID: String
    var timeIn: Date?
    var timeOut: Date?
    
    init(employeeID: String) {
        self.employeeID = employeeID
        
        // ID variable is for FireStore storing and labeling purposes, same as employeeID
        self.id = employeeID
    }
    
    /* Required code to make the EmployeeTimecard struct Codable and Hashable */
    
    private enum CodingKeys: String, CodingKey {
        case timeIn
        case timeOut
        case employeeID
    }
    
    // getTimeIn
    // Grabs timeIn variable from timecard, transforms
    // it into "hh:mm:ss a" format, then returns result
    
    // Primary use is for displaying dates in app
    
    // TO-DO: Rename func?
    // Current name may not be specific enough as it returns a modified timeIn var
    
    func getTimeIn() -> String {
        var fancyTimeIn: String = ""
        
        if let time = timeIn {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mm:ss a"
            fancyTimeIn = dateFormatter.string(from: time)
        }
        print("timeIn: \(fancyTimeIn)")
        return fancyTimeIn
    }
    
    // getTimeOut
    // Grabs timeOut variable from timecard, transforms
    // it into "hh:mm:ss a" format, then returns result
    
    // Primary use is for displaying dates in app
    
    // TO-DO: Rename func?
    // Current name may not be specific enough as it returns a modified timeOut var
    
    func getTimeOut() -> String {
        var fancyTimeOut: String = ""
        
        if let time = timeOut {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mm:ss a"
            fancyTimeOut = dateFormatter.string(from: time)
        }
        print("timeOut: \(fancyTimeOut)")
        return fancyTimeOut
    }
    
    // getID
    // Returns copy of employeeID var for the current timecard
    
    func getID() -> String {
        let id: String = self.employeeID
        return id
    }
    
    // hasClockedIn
    // Checks if timeIn variable is nil, if so
    // then return false, otherwise return true.
    //
    // Primary use is to check whether an
    // employee needs to clock in or clock out
    
    func hasClockedIn() -> Bool {
        if self.timeIn == nil {
            return false
        }
        else {
            return true
        }
    }
    
    // hasClockedOut
    // Checks if timeOut variable is nil, if so
    // then return false, otherwise return true.
    //
    // Primary use is to check whether an
    // employee needs to clock in or clock out
    
    func hasClockedOut() -> Bool {
        if self.timeOut == nil {
            return false
        }
        else {
            return true
        }
    }
}
