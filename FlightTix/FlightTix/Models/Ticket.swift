//
//  Ticket.swift
//  FlightTix
//
//  Created by Jon Bauer on 11/17/24.
//

import Foundation

struct Ticket {
    let id: UUID = UUID()
    let flight: Flights.ID
    let price: Double
    let traveller: Traveller
}
