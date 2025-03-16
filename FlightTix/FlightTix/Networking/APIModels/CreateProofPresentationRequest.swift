//
//  CreateProofPresentationRequest.swift
//  FlightTix
//
//  Created by Jon Bauer on 3/1/25.
//

import Foundation

struct CreateProofPresentationRequest: Encodable {
    let goalCode: String
    let goal: String
    let connectionId: String
    let options: Options
    let proofs: [ProofRequestAux] // What is ProofRequestAux type?
    //let anoncredPresentationRequest: String
    //let presentationFormat: String
    //let claims: [String: String] for SD-JWT
    //let credentialFormat: String for SD-JWT
    
    struct Options: Encodable {
        let challenge: String
        let domain: String
    }
    
    struct ProofRequestAux: Encodable {}
}
