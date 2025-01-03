//
//  DIDsOnCloudAgentResponse.swift
//  FlightTix
//
//  Created by Jon Bauer on 1/2/25.
//

import Foundation

struct DIDsOnCloudAgentResponse: Decodable {
    let `self`: String
    let kind: String
    let pageOf: String
    let contents: [DIDContents?]
}

struct DIDContents: Decodable {
    let did: String
    let status: String
}
