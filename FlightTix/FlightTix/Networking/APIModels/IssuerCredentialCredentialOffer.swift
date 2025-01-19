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
    //let subjectId: String?
    let validityPeriod: Double
    let claims: PassportClaimsRequest // Does not contain a DID
    let automaticIssuance: Bool
    let createdAt: String
    //let updatedAt: String
    let role: String
    let protocolState: String
    //let credential: String?
    //let issuingDid: String?
    //let goalCode: String? // these are no longer supported
    //let goal: String? // these are no longer supported
    //let myDid: String?
    //let invitation: InvitationAPIModel
    let metaRetries: Int
    //let metaLastFailure: CredentialOfferErrorResponseAPIModel    
}

public struct CreateCredentialOfferRequest: Encodable, Sendable {
    let validityPeriod: Int
    let schemaId: String
    //let credentialDefinitionId: String?
    let credentialFormat: String
    let claims: PassportClaimsRequest
    let automaticIssuance: Bool
    let issuingDID: String
    //let issuingKid: String
    let connectionId: String
//    let goalCode: String // Not supported
//    let goal: String // Not supported
}

struct PassportClaimsRequest: Codable, Sendable {
    let name: String
    let dateOfIssuance: String
    let passportNumber: String
    let dob: String
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
