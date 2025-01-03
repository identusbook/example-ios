//
//  File.swift
//  FlightTix
//
//  Created by Jon Bauer on 1/2/25.
//

import Foundation

struct CreateDIDRequest: Encodable {
    let documentTemplate: DocumentTemplate
}

struct DocumentTemplate: Encodable {
    let publicKeys: [DIDPublicKey]
    let services: [DIDService?]
}

struct DIDPublicKey: Encodable {
    let id: String
    let purpose: String
    //let curve: String? // Can use Default
}

struct DIDService: Encodable {} // TBD
