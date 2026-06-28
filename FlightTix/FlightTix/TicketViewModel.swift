//
//  TicketViewModel.swift
//  FlightTix
//
//  Created by Jon Bauer on 1/1/25.
//

import Foundation
import EdgeAgentSDK

class TicketViewModel: ObservableObject {
    
    final class CanNotReadTicketSchemaError: Error {}
    final class CanNotFindTicketCredentialError: Error {}
    final class CanNotGetTicketDetailsError: Error {}
    
    @Published var ticket: Ticket?
    
    public func issueTicket(for flight: Flight) async throws {
        do {
            
            print("Issue Ticket for \(flight)")
            
            // Get IssuerDID and verify it's been published.
            guard let issuerDID = Identus.shared.readIssuerDIDFromKeychain() else {
                return
            }
            guard let shortFormIssuerDID = try await Identus.shared.didShortForm(from: issuerDID) else {
                return
            }
            guard try await Identus.shared.verifyIssuerDIDIsPublished(shortOrLongFormDID: shortFormIssuerDID.string) else { return
            }
            // Get Ticket SchemaId
            guard let ticketSchemaId = Identus.shared.readTicketSchemaIdFromKeychain() else {
                return
            }
            
            // Get ConnectionId
            guard let currentConnectionId = Identus.shared.readConnectionIdFromKeychain() else {
                return
            }

            do {
                let credentialOffer = try await Identus.shared.createTicketCredentialOffer(request: CreateTicketCredentialOfferRequest(
                    validityPeriod: 3600,
                    schemaId: "\(FlightTixSessionConfigStruct().baseURL)/schema-registry/schemas/\(ticketSchemaId)/schema", // Must match the proof-request schema URL exactly (host included); the Cloud Agent string-compares them during verification.
                    credentialFormat: "JWT",
                    claims: TicketClaimsRequest(name: flight.id.uuidString,
                                                dateOfIssuance: Date.now.iso8601String(),
                                                flightId: flight.id.uuidString,
                                                price: flight.price,
                                                departure: flight.departure,
                                                arrival: flight.arrival),
                    automaticIssuance: true,
                    issuingDID: shortFormIssuerDID.string,
                    connectionId: currentConnectionId
                ))
                print("We should have created a CreditentialOffer at this point \(String(describing: credentialOffer))")
               
                // Store thid as identifier we can use to track the response from DIDComm
                guard Identus.shared.storeTicketVCThidInKeychain(thid: credentialOffer.thid) else { return }
                
                } catch {
                    print("Credential Record failed with error: \(error)")
                }

        } catch {
            print(error)
        }
    }

    @MainActor
    func getTicket() async throws {
        // Set on the main actor before returning so the view sees `ticket`
        // populated by the time it stops showing the loading state.
        self.ticket = try await getTicketDetails()
    }
    
    func getTicketDetails() async throws -> Ticket {
        guard let ticketSchemaID = Identus.shared.readTicketSchemaIdFromKeychain() else {
            throw CanNotReadTicketSchemaError()
        }
        guard let cred = try await Identus.shared.fetchCredential(ofSchema: ticketSchemaID) else {
            throw CanNotFindTicketCredentialError()
        }
        
        let claimValues = populateTicketClaims(claims: cred.claims)
        let priceAsDouble = (claimValues.price! as NSString).doubleValue
        
        let ticket: Ticket = Ticket(price: priceAsDouble,
                            departure: claimValues.departure ?? "",
                            arrival: claimValues.arrival ?? "")
        return ticket
    }
    
    private func populateTicketClaims(claims: [Claim]) -> (flightId: String?, price: String?, departure: String?, arrival: String?, dateOfIssuance: String?) {
        var flightId: String?
        var price: String?
        var departure: String?
        var arrival: String?
        var dateOfIssuance: String?
        for claim in claims {
            if claim.key == "flightId" {
                flightId = claim.getValueAsString()
            }
            if claim.key == "price" {
                price = claim.getValueAsString()
            }
            if claim.key == "departure" {
                departure = claim.getValueAsString()
            }
            if claim.key == "arrival" {
                arrival = claim.getValueAsString()
            }
            if claim.key == "dateOfIssuance" {
                let doiString = claim.getValueAsString()
                let prettyDOi = DateStuff.displayISODateAsString(doiString, showTime: false)
                dateOfIssuance = prettyDOi
            }
        }
        return (flightId, price, departure, arrival, dateOfIssuance)
    }
}
