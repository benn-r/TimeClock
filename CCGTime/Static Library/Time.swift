//
//  Time.swift
//  CCGTime
//
//  Created by Ben on 5/12/23.
//
//  Time class to be used for displaying time in different formats

import Foundation


class Time {
    
    class func fancyTime() -> String {
        let date = Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm:ss a"
        let formattedTime = dateFormatter.string(from: date)
        
        return formattedTime
    }
    
}
