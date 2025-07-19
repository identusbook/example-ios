//
//  IdentusStatus.swift
//  FlightTix
//
//  Created by Jon Bauer on 7/13/25.
//

import Foundation

enum IdentusStatusState: Equatable {
    case disconnected
    case connected
    case publishingIssuerDID
    case issuerDIDPublished
    case startingAgent
    case startingDIDCommMessageListener
    case creatingConnectionToCloudAgent
    case issuerDIDAlreadyExists
    case creatingIssuerDID
    case checkingPassportSchema
    case creatingPassportSchema
    case createdPassportSchema
    case ready
    case error(Error)
    
    var description: String {
        switch self {
        case .disconnected:
            return "Disconnected"
        case .connected:
            return "Connected"
        case .publishingIssuerDID:
            return "Publishing Issuer DID"
        case .issuerDIDPublished:
            return "Issuer DID Published"
        case .checkingPassportSchema:
            return "Checking Passport Schema"
        case .creatingPassportSchema:
            return "Creating Passport Schema"
        case .createdPassportSchema:
            return "Created Passport Schema"
        case .ready:
            return "Ready"
        case .startingAgent:
            return "Starting Agent"
        case .error(let error):
            return "Error: \(error.localizedDescription)"
        case .startingDIDCommMessageListener:
            return "Starting DIDComm Message Listener"
        case .creatingConnectionToCloudAgent:
            return "Creating Connection to Cloud Agent"
        case .issuerDIDAlreadyExists:
            return "Isser DID Already Exists"
        case .creatingIssuerDID:
            return "Creating New Issuer DID"
        }
    }
    
    static func == (lhs: IdentusStatusState, rhs: IdentusStatusState) -> Bool {
            switch (lhs, rhs) {
            case (.disconnected, .disconnected),
                (.connected, .connected),
                (.publishingIssuerDID, .publishingIssuerDID),
                (.issuerDIDPublished, .issuerDIDPublished),
                (.ready, .ready),
                (.startingAgent, .startingAgent),
                (.startingDIDCommMessageListener, .startingDIDCommMessageListener),
                (.creatingConnectionToCloudAgent, .creatingConnectionToCloudAgent),
                (.issuerDIDAlreadyExists, .issuerDIDAlreadyExists),
                (.creatingIssuerDID, .creatingIssuerDID),
                (.checkingPassportSchema, .checkingPassportSchema),
                (.creatingPassportSchema, .creatingPassportSchema),
                (.createdPassportSchema, .createdPassportSchema):
                return true
            default:
                return false
            }
        }
}

final class IdentusStatus: ObservableObject {
    @Published var status: IdentusStatusState = .disconnected
    
    static let shared = IdentusStatus()
    private init() {}
}
