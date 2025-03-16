//
//  PassportSchema.swift
//  FlightTix
//
//  Created by Jon Bauer on 1/18/25.
//

import Foundation

struct PassportSchema: Codable {
    let guid: String?
    let name: String
    let version: String
    let description: String
    let type: String
    let author: String
    let tags: [String]
    let schema: PassportSchemaData
}

struct PassportSchemaData: Codable {
    let id: String
    let schema: String
    let description: String
    let type: String
    let properties: PassportProperties
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

struct PassportProperties: Codable {
    let name: PropertyDetails
    let dateOfIssuance: PropertyDetails
    let passportNumber: PropertyDetails
    let dob: PropertyDetails
}

//struct PropertyDetails: Codable {
//    let type: String
//    let format: String?
//}
