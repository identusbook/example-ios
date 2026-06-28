//
//  PurchaseViewModel.swift
//  FlightTix
//
//  Created by Jon Bauer on 7/20/25.
//

import Foundation

class PurchaseViewModel: ObservableObject {
    
    final class TicketCreateCredentialOfferError: Error {}
    final class TicketCreateProofRequestError: Error {}
    final class TicketGetPresentationsError: Error {}
    final class TicketReadIssuerFromKeychainFailedError: Error {}
    final class TicketGetDIDShortFormFailedError: Error {}
    final class TicketVerifyIssuerDIDIsPublishedError: Error {}
    final class TicketReadTicketSchemaIDFromKeychainError: Error {}
    final class TicketConnectionIDFromKeychainError: Error {}
    final class TicketStoreThidInKeychainError: Error {}
    
    @Published var purchaseComplete: Bool = false
    @Published var availableFlights: [Flight] = FlightSearch.availableFlights()
    
    func purchaseTicket(for flight: Flight) async throws {
        
        do {
            
            print("Request Credential Offer for Ticket")
            // TODO:  Should we do this here? Probably on startup?
            try await Identus.shared.createTicketSchemaIfNotExists()
            
            // Get IssuerDID and verify it's been published.
            guard let issuerDID = Identus.shared.readIssuerDIDFromKeychain() else {
                print("Could not read Issuer DID from keychain!")
                throw TicketReadIssuerFromKeychainFailedError()
            }
            guard let shortFormIssuerDID = try await Identus.shared.didShortForm(from: issuerDID) else {
                print("Could not get short form DID from keychain!")
                throw TicketGetDIDShortFormFailedError()
            }
            guard try await Identus.shared.verifyIssuerDIDIsPublished(shortOrLongFormDID: shortFormIssuerDID.string) else
            {
                print("Issuer DID is not yet Published!")
                throw TicketVerifyIssuerDIDIsPublishedError()
            }
            
            // Get Passport SchemaId
            guard let ticketSchemaId = Identus.shared.readTicketSchemaIdFromKeychain() else {
                print("Could not read Ticket Schema ID from keychain!")
                throw TicketReadTicketSchemaIDFromKeychainError()
            }
            
            // Get ConnectionId
            guard let currentConnectionId = Identus.shared.readConnectionIdFromKeychain() else {
                print("Could not read Connection ID from keychain!")
                throw TicketConnectionIDFromKeychainError()
            }
            
            let credentialOffer = try await Identus.shared.createTicketCredentialOffer(request: CreateTicketCredentialOfferRequest(
                validityPeriod: 3600,
                schemaId: "\(FlightTixSessionConfigStruct.init().baseURL)/schema-registry/schemas/\(ticketSchemaId)/schema", // TODO: make this baseURL dynamic.  it's very important to be THIS baseURL, Cloud Agent can't dereference it from Docker if's different.  This should only be this way for dev.  Prod needs a real live URL
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
            
            // Store thid as identifier we can use to track the response from DIDComm
            guard Identus.shared.storeTicketVCThidInKeychain(thid: credentialOffer.thid) else {
                throw TicketStoreThidInKeychainError()
            }

            // The offer is created and auto-issuance kicked off, but the credential is
            // actually issued over DIDComm a moment later. Wait until the issuer reports
            // it sent so the button's busy state covers the full request → issue cycle.
            try await awaitCredentialIssued(recordId: credentialOffer.recordId)

            Task { @MainActor in
                purchaseComplete = true
            }

        } catch {
            print(error)
            throw TicketCreateCredentialOfferError()
        }
    }

    /// Poll the Cloud Agent's issue-credential record until the credential has been
    /// issued (or we time out), so the UI can show a busy state for the whole flow.
    private func awaitCredentialIssued(recordId: String, timeout: TimeInterval = 90) async throws {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if let record = try? await Identus.shared.credentialRecord(recordId: recordId),
               record.protocolState == "CredentialSent" {
                return
            }
            try await Task.sleep(nanoseconds: 2_000_000_000)
        }
        throw TicketCreateCredentialOfferError()
    }

}
