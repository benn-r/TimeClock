//
//  Timesheet.swift
//  CCGTime
//
//  Created by ben on 7/17/22.
//

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
        self.id = employeeID
    }
    
    private enum CodingKeys: String, CodingKey {
        case timeIn
        case timeOut
        case employeeID
    }
    
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
    
    func getID() -> String {
        let id: String = self.employeeID
        return id
    }
    
    func hasClockedIn() -> Bool {
        if self.timeIn == nil {
            return false
        }
        else {
            return true
        }
    }
    
    func hasClockedOut() -> Bool {
        if self.timeOut == nil {
            return false
        }
        else {
            return true
        }
    }
}
