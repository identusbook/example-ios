//
//  ProfileViewModel.swift
//  FlightTix
//
//  Created by Jon Bauer on 7/11/25.
//

import Foundation

class ProfileViewModel: ObservableObject {
    
    final class PassportCreateCredentialOfferError: Error {}
    final class PassportCreateProofRequestError: Error {}
    final class PassportGetPresentationsError: Error {}
    final class PassportReadIssuerFromKeychainFailedError: Error {}
    final class PassportGetDIDShortFormFailedError: Error {}
    final class PassportVerifyIssuerDIDIsPublishedError: Error {}
    final class PassportReadPassportSchemaIDFromKeychainError: Error {}
    final class PassportConnectionIDFromKeychainError: Error {}
    final class PassportStoreThidInKeychainError: Error {}
    
    final class TicketCreateCredentialOfferError: Error {}
    final class TicketCreateProofRequestError: Error {}
    final class TicketGetPresentationsError: Error {}
    final class TicketReadIssuerFromKeychainFailedError: Error {}
    final class TicketGetDIDShortFormFailedError: Error {}
    final class TicketVerifyIssuerDIDIsPublishedError: Error {}
    final class TicketReadTicketSchemaIDFromKeychainError: Error {}
    final class TicketConnectionIDFromKeychainError: Error {}
    final class TicketStoreThidInKeychainError: Error {}
    
    
    init() {
        Identus.setup(IdentusConfig())
    }
    
    func tearDown() async throws {
        // tears down app state
        try await Identus.shared.tearDown()
    }
    
    func startUp() async throws {
        // tears down app state
        try await Identus.shared.startUpAndConnect()
    }
    
    func stop() async throws {
        try await Identus.shared.stop()
    }
    
    func issuePassport(passport: Passport) async throws {
        do {
            
            print("Request Credential Offer for Passport")
            
            // Get IssuerDID and verify it's been published.
            guard let issuerDID = Identus.shared.readIssuerDIDFromKeychain() else {
                print("Could not read Issuer DID from keychain!")
                throw PassportReadIssuerFromKeychainFailedError()
            }
            guard let shortFormIssuerDID = try await Identus.shared.didShortForm(from: issuerDID) else {
                print("Could not get short form DID from keychain!")
                throw PassportGetDIDShortFormFailedError()
            }
            guard try await Identus.shared.verifyIssuerDIDIsPublished(shortOrLongFormDID: shortFormIssuerDID.string) else
            {
                print("Issuer DID is not yet Published!")
                throw PassportVerifyIssuerDIDIsPublishedError()
            }
            
            // TODO: why does this fail?
            // Get Passport SchemaId
            guard let passportSchemaId = Identus.shared.readPassportSchemaIdFromKeychain() else {
                print("Could not read Passport Schema ID from keychain!")
                throw PassportReadPassportSchemaIDFromKeychainError()
            }
            
            // Get ConnectionId
            guard let currentConnectionId = Identus.shared.readConnectionIdFromKeychain() else {
                print("Could not read Connection ID from keychain!")
                throw PassportConnectionIDFromKeychainError()
            }
            
            let credentialOffer = try await Identus.shared.createPassportCredentialOffer(request: CreateCredentialOfferRequest(
                validityPeriod: 3600,
                schemaId: "\(FlightTixSessionConfigStruct.init().baseURL)/schema-registry/schemas/\(passportSchemaId)/schema", // TODO: make this baseURL dynamic.  it's very important to be THIS baseURL, Cloud Agent can't dereference it from Docker if's different.  This should only be this way for dev.  Prod needs a real live URL
                credentialFormat: "JWT",
                claims: PassportClaimsRequest(name: passport.name,
                                              dateOfIssuance: Date.now.iso8601String(),
                                              passportNumber: passport.passportNumber,
                                              dob: passport.dob.iso8601String()),
                automaticIssuance: true,
                issuingDID: shortFormIssuerDID.string,
                connectionId: currentConnectionId
            ))
            
            // Store thid as identifier we can use to track the response from DIDComm
            guard Identus.shared.storePassportVCThidInKeychain(thid: credentialOffer.thid) else {
                throw PassportStoreThidInKeychainError()
            }

        } catch {
            print(error)
            throw PassportCreateCredentialOfferError()
        }
    }
    
    func issueTicket(for flight: Flight) async throws {
        do {
            
            print("Request Credential Offer for Ticket")
            
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
                                          flight: flight),
                automaticIssuance: true,
                issuingDID: shortFormIssuerDID.string,
                connectionId: currentConnectionId
            ))
            
            // Store thid as identifier we can use to track the response from DIDComm
            guard Identus.shared.storeTicketVCThidInKeychain(thid: credentialOffer.thid) else {
                throw TicketStoreThidInKeychainError()
            }

        } catch {
            print(error)
            throw TicketCreateCredentialOfferError()
        }
    }
    
    public func requestProofOfPassport() async throws -> PresentationResponseContent {
        
        guard let passportSchemaId = Identus.shared.readPassportSchemaIdFromKeychain() else {
            throw Identus.PassportFailedToReadFromKeychainError()
        }
        
        do {
            // This creates a Proof Presentation Request
            guard let presentation = try await Identus.shared.createProofRequest(schemaId: passportSchemaId) else {
                throw PassportCreateProofRequestError()
            }
            return presentation
            
        } catch {
            print(error)
            throw PassportCreateProofRequestError()
        }
        
        
        // TODO: Fix getPresentations() - for some reason the result doesn't parse
//        do {
//            // Let's check the list of active Proof Presentation Requests
//            let presentationRequestsList = try await Identus.shared.getPresentations()
//
//            print("List of Presentations is: \(String(describing: presentationRequestsList))")
//        } catch {
//            print(error)
//            throw PassportGetPresentationsError()
//        }
            
    }
    
    public func requestProofOfTicket() async throws -> PresentationResponseContent {
        
        guard let ticketSchemaId = Identus.shared.readTicketSchemaIdFromKeychain() else {
            throw Identus.PassportFailedToReadFromKeychainError()
        }
        
        do {
            // This creates a Proof Presentation Request
            guard let presentation = try await Identus.shared.createProofRequest(schemaId: ticketSchemaId) else {
                throw TicketCreateProofRequestError()
            }
            return presentation
            
        } catch {
            print(error)
            throw TicketCreateProofRequestError()
        }
        
        
        // TODO: Fix getPresentations() - for some reason the result doesn't parse
//        do {
//            // Let's check the list of active Proof Presentation Requests
//            let presentationRequestsList = try await Identus.shared.getPresentations()
//
//            print("List of Presentations is: \(String(describing: presentationRequestsList))")
//        } catch {
//            print(error)
//            throw PassportGetPresentationsError()
//        }
            
    }
}
