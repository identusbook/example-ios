//
//  RegisterViewModel.swift
//  FlightTix
//
//  Created by Jon Bauer on 12/20/24.
//

import Foundation

class RegisterViewModel: ObservableObject {
    
    public func register(passport: Passport) async throws {
        do {
            
            print("Handle Registration / Login VC Issuance here")
            // Save Passport info in keychain
            // Request Airline to Issue a Login VC
            // Wait for Issuance
            
            
            // if VC success, set login status
            try await Auth.shared.login(passport: passport)
        } catch {
            print(error)
        }
    }
}
