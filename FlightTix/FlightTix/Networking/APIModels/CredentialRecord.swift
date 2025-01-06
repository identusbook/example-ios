//
//  CredentialRecord.swift
//  FlightTix
//
//  Created by Jon Bauer on 12/29/24.
//

import Foundation

struct CredentialRecordResponse: Decodable {
    let recordId: String
    let thid: String
    let credentialFormat: String
    //let subjectId: String
    //let validityPeriod: String
    let claims: PassportClaimsRequest // Does not contain a DID
    let automaticIssuance: Bool
    let createdAt: String
    //let updatedAt: String
    let role: String
    let protocolState: String
    //let credential: String
    //let issuingDid: String
    //let goalCode: String
    //let goal: String
    //let myDid: String
    //let invitation: InvitationAPIModel
    let metaRetries: Int
    //let metaLastFailure: CredentialOfferErrorResponseAPIModel
}

struct AcceptCredentialOfferRequest: Encodable {
    let subjectId: String
    let keyId: String
}

