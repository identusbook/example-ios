//
//  InvitationAPIModel.swift
//  FlightTix
//
//  Created by Jon Bauer on 12/22/24.
//

import Foundation

public struct CreateInvitationResponse: Decodable, Sendable {
    let connectionId: String
    let kind: String
    let label: String
    let `self`: String
    let state: String
    let createdAt: String
    let invitation: InvitationAPIModel
}

struct InvitationAPIModel: Codable, Sendable {
    let from: String
    let id: String
    let invitationUrl: String
    let type: String?
}

public struct CreateInvitationRequest:  Encodable, Sendable {
    let label: String
}
