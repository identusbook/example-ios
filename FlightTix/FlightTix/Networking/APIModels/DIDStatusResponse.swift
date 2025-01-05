//
//  DIDStatusResponse.swift
//  FlightTix
//
//  Created by Jon Bauer on 1/2/25.
//

import Foundation

struct DIDStatusResponse: Decodable {
    let did: String
    let status: String
}
