//
//  IssuerCredentialCredentialOffer.swift
//  FlightTix
//
//  Created by Jon Bauer on 12/29/24.
//

import Foundation

public struct CreateCredentialOfferResponse: Decodable, Sendable {
    let recordId: String
    let thid: String
    let credentialFormat: String
    let validityPeriod: Double
    let claims: PassportClaimsRequest // Does not contain a DID
    let automaticIssuance: Bool
    let createdAt: String
    let role: String
    let protocolState: String
    let metaRetries: Int
}

public struct CreateTicketCredentialOfferResponse: Decodable, Sendable {
    let recordId: String
    let thid: String
    let credentialFormat: String
    let validityPeriod: Double
    let claims: TicketClaimsRequest // Does not contain a DID
    let automaticIssuance: Bool
    let createdAt: String
    let role: String
    let protocolState: String
    let metaRetries: Int
}

public struct CreateCredentialOfferRequest: Encodable, Sendable {
    let validityPeriod: Int
    let schemaId: String
    let credentialFormat: String
    let claims: PassportClaimsRequest
    let automaticIssuance: Bool
    let issuingDID: String
    let connectionId: String
}

public struct CreateTicketCredentialOfferRequest: Encodable, Sendable {
    let validityPeriod: Int
    let schemaId: String
    let credentialFormat: String
    let claims: TicketClaimsRequest
    let automaticIssuance: Bool
    let issuingDID: String
    let connectionId: String
}

struct PassportClaimsRequest: Codable, Sendable {
    let name: String
    let dateOfIssuance: String
    let passportNumber: String
    let dob: String
}

struct TicketClaimsRequest: Codable, Sendable {
    let name: String
    let dateOfIssuance: String
    let flight: Flight
}

struct CredentialOfferErrorResponseAPIModel: Decodable, Sendable {
    let status: Int
    let type: String
    let title: String
    let detail: String
    let instance: String
}

enum CredentialFormat: String, Codable {
    case JWT = "JWT"
}
