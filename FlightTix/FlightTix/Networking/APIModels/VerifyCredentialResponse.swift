//
//  VerifyCredentialResponse.swift
//  FlightTix
//
//  Created by Jon Bauer on 3/1/25.
//

import Foundation

struct VerifyCredentialResponse: Decodable {
    let credential: String
    let result: [VerifyCredentialResult]
}

struct VerifyCredentialResult: Decodable {
    let verification: String
    let success: Bool
}
