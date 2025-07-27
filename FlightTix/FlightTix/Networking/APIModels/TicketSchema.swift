//
//  TicketSchema.swift
//  FlightTix
//
//  Created by Jon Bauer on 1/28/25.
//

import Foundation

struct TicketSchema: Codable {
    let guid: String?
    let name: String
    let version: String
    let description: String
    let type: String
    let author: String
    let tags: [String]
    let schema: TicketSchemaData
}

struct TicketSchemaData: Codable {
    let id: String
    let schema: String
    let description: String
    let type: String
    let properties: TicketProperties
    let required: [String]
    let additionalProperties: Bool

    enum CodingKeys: String, CodingKey {
        case id = "$id"
        case schema = "$schema"
        case description
        case type
        case properties
        case required
        case additionalProperties
    }
}

struct TicketProperties: Codable {
    let name: PropertyDetails
    let dateOfIssuance: PropertyDetails
    let price: PropertyDetails
    let departure: PropertyDetails
    let arrival: PropertyDetails
    let flightId: PropertyDetails
}

struct PropertyDetails: Codable {
    let type: String
    let format: String?
}
