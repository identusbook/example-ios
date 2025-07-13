//
//  VCSchemas.swift
//  FlightTix
//
//  Created by Jon Bauer on 7/13/25.
//

import Foundation

// VC Schema

struct VerifiableCredentialEnvelope: Decodable {
    let iss: String
    let sub: String
    let nbf: Int
    let exp: Int
    let vc: VerifiableCredential
}

struct VerifiableCredential: Decodable {
    let credentialSchema: [CredentialSchema]
    let credentialSubject: CredentialSubject
    let type: [String]
    let context: [String]
    let issuer: Issuer
    let credentialStatus: CredentialStatus

    enum CodingKeys: String, CodingKey {
        case credentialSchema
        case credentialSubject
        case type
        case context = "@context"
        case issuer
        case credentialStatus
    }
}

struct CredentialSchema: Decodable {
    let id: String
    let type: String
}

struct CredentialSubject: Decodable {
    let id: String
    let name: String
    let did: String?
    let passportNumber: String
    let dob: Date
    let dateOfIssuance: String
}

struct Issuer: Decodable {
    let id: String
    let type: String
}

struct CredentialStatus: Decodable {
    let statusPurpose: String
    let statusListIndex: Int
    let id: String
    let type: String
    let statusListCredential: String
}


// Ticket VCSchema

struct TicketVerifiableCredentialEnvelope: Decodable {
    let iss: String
    let sub: String
    let nbf: Int
    let exp: Int
    let vc: TicketVerifiableCredential
}

struct TicketVerifiableCredential: Decodable {
    let credentialSchema: [TicketCredentialSchema]
    let credentialSubject: TicketCredentialSubjectContainer
    let type: [String]
    let context: [String]
    let issuer: TicketIssuer
    let credentialStatus: TicketCredentialStatus

    enum CodingKeys: String, CodingKey {
        case credentialSchema
        case credentialSubject
        case type
        case context = "@context"
        case issuer
        case credentialStatus
    }
}

struct TicketCredentialSubjectContainer: Decodable {
    let id: String
    let flight: String
    let price: Double
    //let traveller: Traveller
}

struct TicketCredentialSchema: Decodable {
    let id: String
    let type: String
}

struct TicketIssuer: Decodable {
    let id: String
    let type: String
}

struct TicketCredentialStatus: Decodable {
    let statusPurpose: String
    let statusListIndex: Int
    let id: String
    let type: String
    let statusListCredential: String
}
