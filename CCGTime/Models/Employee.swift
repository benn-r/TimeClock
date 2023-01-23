//
//  Employee.swift
//  CCGTime
//
//  Created by ben on 7/17/22.
//

import Foundation
import FirebaseFirestoreSwift

struct Employee: Codable, Hashable {
    
    @DocumentID var id: String?
    var firstName: String
    var lastName: String
    var wage: Double
    var department: String
    var name: String
    
    private enum CodingKeys: String, CodingKey {
        case firstName
        case lastName
        case name
        case wage
        case department
    }
    
    init(firstName: String, lastName: String, wage: Double, department: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.wage = wage
        self.department = department
        self.name = "\(firstName) \(lastName)"
    }
}
