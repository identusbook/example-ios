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
        // Get Credentials
        var credentials: [Credential]?
        do {
            credentials = try await Identus.shared.fetchCredentials()
        } catch {
            print("Error fetching credentials: \(error)")
        }
        
        guard let credentials else { return false }
        for credential: Credential in credentials {
            
            print("Credential is: \(credential)")
            
            // Check for a PassportVC by checking the credentialSchema
            // if credential.verifiableCredential.credentialSchema == knownPassportVCSchemaID { return true }
            
            return true
        }
        
        return false
    }
}
