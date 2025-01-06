//
//  Date+APIFormatter.swift
//  FlightTix
//
//  Created by Jon Bauer on 1/5/25.
//

import Foundation

extension Date {
    
    public func iso8601String() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm'Z'" // ISO 8601 format
        formatter.timeZone = TimeZone(abbreviation: "UTC") // Set timezone to UTC
        return formatter.string(from: self)
    }
    
    public func stringToDate(iso8601String: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm'Z'" // ISO 8601 format
        formatter.timeZone = TimeZone(abbreviation: "UTC") // Set timezone to UTC
        guard let date = formatter.date(from: iso8601String) else { return nil }
        return date
    }
}
