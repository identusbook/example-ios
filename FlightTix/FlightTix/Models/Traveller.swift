//
//  Traveller.swift
//  FlightTix
//
//  Created by Jon Bauer on 11/17/24.
//


import Foundation

struct Traveller {
    let id: UUID = UUID()
    let name: String
    let did: String
    let passportNumber: String
    let dob: Date
    var tickets: [Ticket] = []
        
    public func createDID() {
        // Create DID with SDK
        // save DID
    }
    
    public mutating func purchase(ticket: Ticket) async throws {
        //connect to Airline
        //purchase ticket
        //airline issues VC
        tickets.append(ticket)
    }
    
    private func save() {
        //persist Traveller in keychain
    }
}