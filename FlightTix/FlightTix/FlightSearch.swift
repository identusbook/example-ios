//
//  FlightSearch.swift
//  FlightTix
//
//  Created by Jon Bauer on 7/20/25.
//

import Foundation

struct FlightSearch {
    
    public static func availableFlights() -> [Flight] {
        return [
                Flight(departure: "ATL", arrival: "SCL", price: 500.00),
                Flight(departure: "SFO", arrival: "TYO", price: 800.00),
                Flight(departure: "LAS", arrival: "VIE", price: 700.00),
        ]
    }
}
