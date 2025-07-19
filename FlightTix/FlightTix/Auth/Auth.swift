//
//  Auth.swift
//  FlightTix
//
//  Created by Jon Bauer on 12/15/24.
//

import Foundation
import EdgeAgentSDK

class Auth: ObservableObject {
    
    // Singleton
    static let shared = Auth()
    private init() {}
    
    private var authValid: Bool = false
    private var agent: EdgeAgent?
    
    public func logout() async throws {
        // Delete or Revoke Passport VC Credential
        authValid = false
    }

    public func isLoggedIn() async -> Bool {
        
        if !authValid {
            do {
                let loginVCExists = try await loginVCExists()
                if loginVCExists { authValid = true }
            } catch {
                print(error)
            }
        }
    
        return authValid
    }
    
    private func loginVCExists() async throws -> Bool {
        // Check for Passport VC
        guard let passportSchemaID = Identus.shared.readPassportSchemaIdFromKeychain() else { return false }
        guard let cred = try await Identus.shared.fetchCredential(ofSchema: passportSchemaID) else {
            return false
        }
        
        return true
    }
}
