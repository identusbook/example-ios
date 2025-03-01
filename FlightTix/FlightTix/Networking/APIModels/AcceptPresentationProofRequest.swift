//
//  AcceptPresentationProofRequest.swift
//  FlightTix
//
//  Created by Jon Bauer on 3/1/25.
//

import Foundation

struct AcceptPresentationProofRequest: Encodable {
    let action: String
    let proofId: [String]
    let anonymousCredentialPresentationRequest: AcceptPresentationCredentialProofs
    let claims: [String: String]
    let credentialFormat: String
}

struct AcceptPresentationCredentialProofs: Encodable {
    let credential: String
    let requestedAttribute: [String]
    let requestedPredicate: [String]
}
