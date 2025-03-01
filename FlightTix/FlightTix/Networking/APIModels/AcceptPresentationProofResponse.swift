//
//  AcceptPresentationProofResponse.swift
//  FlightTix
//
//  Created by Jon Bauer on 3/1/25.
//

import Foundation

struct AcceptPresentationProofResponse: Decodable {
    let presentationId: String
    let thid: String
    let role: String
    let status: String
    let proofs: [String]
    let data: [String] //figure out correct data format here
    let requestData: [String] //figure out correct data format here
    let connectionId: String
    let goalCode: String
    let goal: String
    let myDid: String
    let invitation: PresentationResponseInvitation
    let metaRetries: Int
    let metaLastFailure: MetaLastFailure?
}

struct MetaLastFailure: Decodable {
    let status: String
    let type: String
    let detail: String
    let instance: String
}
