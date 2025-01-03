//
//  TicketViewModel.swift
//  FlightTix
//
//  Created by Jon Bauer on 1/1/25.
//

import Foundation

class TicketViewModel: ObservableObject {
    
    public func showCredentials() async throws {
        do {
            try await Identus.shared.listCredentials()
            
        } catch {
            
        }
        
        
    }
}
