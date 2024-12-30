//
//  Report.swift
//  CCGTime
//
//  Created by ben on 12/28/24.
//

import Foundation
import xlsxwriter

class Report {
    
    @Published var fileUrl: URL
    @Published var completed: Bool = false
    
    let startDate: Date
    let endDate: Date
    let dept: String
    let fileName: String
    
    private let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    init (start startDate: Date, end endDate: Date, for dept: String) throws {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .short
        formatter.timeZone = TimeZone.current
        
        print("Report Init Start")
        
        self.startDate = startDate
        self.endDate = endDate
        self.dept = dept
        
        //let startDateString = formatter.string(from: startDate)
        //let endDateString = formatter.string(from: endDate)
        
        self.fileName = "\(dept)_Report.xlsx"
        self.fileUrl = documentsUrl.appendingPathComponent(self.fileName)
        
        print("fileUrl: \(fileUrl)")
        
        self.create()
        self.saveXlsx()
    }
    
    func create() {
        
        FileManager.default.changeCurrentDirectoryPath(documentsUrl.path)
        
        print("Current working directory: \(FileManager.default.currentDirectoryPath)")
        //print("Documents directory: \(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0])")
        
        // Create and populate the workbook
        let wb = Workbook(name: fileName)
        defer { wb.close() }
        let ws = wb.addWorksheet(name: "Sheet1")
        
        ws.write(.string("Hello"), [0,0])
        ws.write(.string("World!"), [0,1])
    }
    
    func saveXlsx() {   
        self.completed = true
    }
}
