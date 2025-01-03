//
//  PublishDIDResponse.swift
//  FlightTix
//
//  Created by Jon Bauer on 1/2/25.
//

import Foundation

public struct PublishDIDResponse: Decodable {
    let scheduledOperation: ScheduledOperation
}

public struct ScheduledOperation: Decodable {
    let id: String
    let didRef: String
}
