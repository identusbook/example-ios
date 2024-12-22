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
    
    public func login(passport: Passport) async throws {
        // Take Passport
        
        // Check for LoginVC
        // if no LoginVC
            //authValid = false
        // else
        authValid = true
    }
    
    public func logout() async throws {
        authValid = false
    }

    public func isLoggedIn() -> Bool { authValid }
    
    private func loginVCExists() async throws -> Bool {
        // Check if LoginVC exists
        return true
    }
}
