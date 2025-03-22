//
//  AcceptPresentationProofRequest.swift
//  FlightTix
//
//  Created by Jon Bauer on 3/1/25.
//

import Foundation

enum PresentationUpdateAction: String, Codable {
    case presentationAccept = "presentation-accept"
    case presentationDeny = "presentation-deny"
    case requestAccept = "request-accept"
    case requestDeny = "request-deny"
}

struct UpdatePresentationProofRequest: Encodable {
    let action: PresentationUpdateAction
    let proofId: [String]?
    let anonymousCredentialPresentationRequest: UpdatePresentationCredentialProofs?
    let claims: [String: String]
    let credentialFormat: String
}

struct UpdatePresentationCredentialProofs: Encodable {
    let credential: String
    let requestedAttribute: [String]
    let requestedPredicate: [String]
}
