//
//  SecurityOfficer.swift
//  FlightTix
//
//  Created by Jon Bauer on 11/17/24.
//

import Foundation

struct SecurityOfficer {
    let id: UUID = UUID()

    public func verifyTicket(traveller: Traveller, ticket: Ticket) async throws -> Bool {
        // request proof of Ticket VC from Traveller
        
        // verify that traveller is the subject of the VC Traveller presents
        return false
    }
    
}
