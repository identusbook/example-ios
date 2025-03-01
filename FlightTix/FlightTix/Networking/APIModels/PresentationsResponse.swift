//
//  PresentationsResponse.swift
//  FlightTix
//
//  Created by Jon Bauer on 3/1/25.
//

import Foundation

public struct PresentationsResponse: Decodable {
    let contents: PresentationResponseContent
    let `self`: String
    let kind: String
    let pageOf: Int
    let next: String
    let previous: String
}

public struct PresentationResponseContent: Decodable {
    let presentationId: String
    let thid: String
    let role: String
    let status: String
    let proofs: [String] // example?
    let data: [String] // Can we make this a Strong type?
    let requestData: [String] // No documentation example on this
    let myDid: String?
    let invitation: PresentationResponseInvitation?
    let connectionId: String
    let metaRetries: Int
}

public struct PresentationResponseInvitation: Decodable {
    let id: String
    let type: String
    let from: String
    let invitationUrl: String
}
