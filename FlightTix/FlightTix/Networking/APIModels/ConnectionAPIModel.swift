//
//  ConnectionAPIModel.swift
//  FlightTix
//
//  Created by Jon Bauer on 12/22/24.
//

import Foundation

public struct ConnectionResponse: Decodable, Sendable {
    let contents: [ConnectionContentAPIModel]
    let kind: String
    let `self`: String
    let pageOf: String
}

struct ConnectionContentAPIModel: Decodable, Sendable {
    let connectionId: String
    let thid: String?
    let label: String?
    let myDid: String?
    let theirDid: String?
    let role: String?
    let state: String?
    let invitation: InvitationAPIModel
    let createdAt: String?
    let updatedAt: String?
    let metaRetries: Int?
    let `self`: String?
    let kind: String?
}
