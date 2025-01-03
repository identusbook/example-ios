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
    //let subjectId: String?
    let validityPeriod: Double
    let claims: PassportClaims
    let automaticIssuance: Bool
    let createdAt: String
    //let updatedAt: String
    let role: String
    let protocolState: String
    //let credential: String?
    //let issuingDid: String?
    //let goalCode: String?
    //let goal: String?
    //let myDid: String?
    //let invitation: InvitationAPIModel
    let metaRetries: Int
    //let metaLastFailure: CredentialOfferErrorResponseAPIModel
    
//    {
//        "recordId": "bc0776c2-79d4-4f49-a4e4-a25ee9cd0311",
//        "thid": "088b8507-2e68-4cd2-b31f-cae04b4a8c01",
//        "credentialFormat": "JWT",
//        "validityPeriod": 3600.0,
//        "claims": {
//            "name": "Jon Bauer",
//            "passportNumber": "987654322",
//            "did": "1234567890",
//            "dateOfIssuance": 757365318.867171,
//            "dob": 757365318.867171
//        },
//        "automaticIssuance": true,
//        "createdAt": "2024-12-31T19:15:18.923633293Z",
//        "role": "Issuer",
//        "protocolState": "OfferPending",
//        "metaRetries": 5
//    }
    
}

public struct CreateCredentialOfferRequest: Encodable, Sendable {
    let label: String
    let validityPeriod: Int
    //let schemaId: String
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
