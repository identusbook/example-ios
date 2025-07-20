//
//  TicketViewModel.swift
//  FlightTix
//
//  Created by Jon Bauer on 1/1/25.
//

import Foundation

class TicketViewModel: ObservableObject {
    
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
                    schemaId: "http://localhost:8085/schema-registry/schemas/\(ticketSchemaId)/schema", // TODO: make this baseURL dynamic.  it's very important to be THIS baseURL, Cloud Agent can't dereference it from Docker if's different.  This should only be this way for dev.  Prod needs a real live URL
                    credentialFormat: "JWT",
                    claims: TicketClaimsRequest(name: flight.id.uuidString,
                                                  dateOfIssuance: Date.now.iso8601String(),
                                                flight: Flight(departure: "SFO", arrival: "TYO", price: 700.0)),
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
    
    public func showCredentials() async throws {
        do {
            try await Identus.shared.listCredentials()
            
        } catch {
            
        }
        
        
    }
}
