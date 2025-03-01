//
//  VerifyCredentialRequest.swift
//  FlightTix
//
//  Created by Jon Bauer on 3/1/25.
//

import Foundation

struct VerifyCredentialRequest: Encodable {
    let credential: String
    let verifications: [Verification]
}

struct Verification: Encodable {
    let verification: String
    let parameter: [String: [String: String]]?
}
