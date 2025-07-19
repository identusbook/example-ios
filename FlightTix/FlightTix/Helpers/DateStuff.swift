//
//  DateStuff.swift
//  FlightTix
//
//  Created by Jon Bauer on 7/19/25.
//

import Foundation

enum DateStuff {
    static func displayISODateAsString(_ isoString: String, showTime: Bool) -> String {

            let timeZoneUTC = TimeZone(secondsFromGMT: 0)
            var date: Date? = nil

            // 1. Try ISO8601DateFormatter with fractional seconds
            let isoParser1 = ISO8601DateFormatter()
            isoParser1.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            isoParser1.timeZone = timeZoneUTC
            date = isoParser1.date(from: isoString)

            // 2. Try ISO8601DateFormatter without fractional seconds
            if date == nil {
                let isoParser2 = ISO8601DateFormatter()
                isoParser2.formatOptions = [.withInternetDateTime]
                isoParser2.timeZone = timeZoneUTC
                date = isoParser2.date(from: isoString)
            }

            // 3. Try custom formatter for "yyyy-MM-dd'T'HH:mmZ"
            if date == nil {
                let fallbackFormatter = DateFormatter()
                fallbackFormatter.dateFormat = "yyyy-MM-dd'T'HH:mmZ"
                fallbackFormatter.locale = Locale(identifier: "en_US_POSIX")
                fallbackFormatter.timeZone = timeZoneUTC
                date = fallbackFormatter.date(from: isoString)
            }

            // 4. Optional: Try plain "yyyy-MM-dd"
            if date == nil {
                let plainDateFormatter = DateFormatter()
                plainDateFormatter.dateFormat = "yyyy-MM-dd"
                plainDateFormatter.locale = Locale(identifier: "en_US_POSIX")
                plainDateFormatter.timeZone = timeZoneUTC
                date = plainDateFormatter.date(from: isoString)
            }

            guard let parsedDate = date else {
                print("❌ Failed to parse: '\(isoString)'")
                return "No Date Format"
            }

            let displayFormatter = DateFormatter()
            displayFormatter.locale = Locale(identifier: "en_US")
            displayFormatter.timeZone = TimeZone.current
            displayFormatter.dateFormat = showTime ? "MMMM d, yyyy 'at' h:mm a" : "MMMM d, yyyy"

            let result = displayFormatter.string(from: parsedDate)
            return result
        }
}
