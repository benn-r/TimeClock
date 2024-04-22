//
//  Department.swift
//  CCGTime
//
//  Created by ben on 5/26/22.
//

import Foundation

class Department: Identifiable {
    
    let id: UUID
    @Published var name: String
    
    init(name: String) {
        self.name = name
        self.id = UUID()
    }
    
//    Potential Future Use
//
//    var dictionary: [String: Any] {
//        return ["documentID": documentID]
//    }
//
//    convenience init(dictionary: [String: Any]) {
//        let documentID = dictionary["documentID"] as! String? ?? ""
//        self.init(documentID: documentID)
//    }
}
