//
//  VerifierPresentationActionRequest.swift
//  FlightTix
//
//  Verifier-side action on a present-proof record.
//  Sent as PATCH /present-proof/presentations/{presentationId}.
//  The Cloud Agent OpenAPI enumerates the verifier actions as
//  "presentation-accept" and "presentation-reject" (proofId is only
//  required for the prover-side "request-accept").
//

import Foundation

struct VerifierPresentationActionRequest: Encodable {
    let action: String

    static let accept = VerifierPresentationActionRequest(action: "presentation-accept")
    static let reject = VerifierPresentationActionRequest(action: "presentation-reject")
}
