//
//  Flight.swift
//  FlightTix
//
//  Created by Jon Bauer on 1/28/25.
//

import Foundation

public struct Flight: Codable, Sendable {
    public var id: UUID = UUID()
    public var departure: String
    public var arrival: String
    public var price: Double
}
