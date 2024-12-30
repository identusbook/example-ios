//
//  IsserCredentialCredentialOffer.swift
//  FlightTix
//
//  Created by Jon Bauer on 12/29/24.
//

import Foundation

public struct CreateCredentialOfferResponse: Decodable, Sendable {
    let recordId: String
    let thid: String
    let credentialFormat: String
    let subjectId: String
    let validityPeriod: String
    let claims: PassportClaims
    let automaticIssuance: Bool
    let createdAt: Date
    let updatedAt: Date
    let role: String
    let protocolState: String
    let credential: String
    let issuingDid: String
    let goalCode: String
    let goal: String
    let myDid: String
    let invitation: InvitationAPIModel
    let metaRetries: Int
    let metaLastFailure: CredentialOfferErrorResponseAPIModel
}

public struct CreateCredentialOfferRequest: Encodable, Sendable {
    let label: String
    let validityPeriod: Int
    let schemaId: String
    //let credentialDefinitionId: String?
    let credentialFormat: String
    let claims: PassportClaims
    let automaticIssuance: Bool
    let issuingDID: String
    //let issuingKid: String
    let connectionId: String
    let goalCode: String
    let goal: String
}

struct PassportClaims: Codable, Sendable {
    let name: String
    let did: String
    let dateOfIssuance: Date
    let passportNumber: String
    let dob: Date
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
