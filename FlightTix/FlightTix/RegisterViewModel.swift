//
//  RegisterViewModel.swift
//  FlightTix
//
//  Created by Jon Bauer on 12/20/24.
//

import Foundation

class RegisterViewModel: ObservableObject {

    final class RegisterCreateCredentialOfferError: Error {}
    final class RegisterCreateProofRequestError: Error {}
    final class RegisterGetPresentationsError: Error {}
    final class RegisterReadIssuerFromKeychainFailedError: Error {}
    final class RegisterGetDIDShortFormFailedError: Error {}
    final class RegisterVerifyIssuerDIDIsPublishedError: Error {}
    final class RegisterReadPassportSchemaIDFromKeychainError: Error {}
    final class RegisterConnectionIDFromKeychainError: Error {}
    final class RegisterStoreThidInKeychainError: Error {}
    
    public func register(passport: Passport) async throws {
        do {
            
            print("Handle Registration / Login VC Issuance here")
            
            // Request Airline to Issue a Passport VC
            // call identus.issueVC(type: .passport, data: passport)
            // must have connection ID inside Identus()
            // Wait for Issuance
            
            /*
             The protocol consists of the following main parts:
             
             The Issuer creates a new credential offer using the /issue-credentials/credential-offers endpoint, which includes information such as the schema identifier and claims.
             The Holder can then retrieve the offer using the /issue-credentials/records endpoint and accept the offer using the /issue-credentials/records/{recordId}/accept-offer endpoint.
             The Issuer then uses the /issue-credentials/records/{recordId}/issue-credential endpoint to issue the credential, which gets sent to the Holder via DIDComm. The Holder receives the credential, and the protocol is complete.
             */
            
            // Get IssuerDID and verify it's been published.
            guard let issuerDID = Identus.shared.readIssuerDIDFromKeychain() else {
                print("Could not read Issuer DID from keychain!")
                throw RegisterReadIssuerFromKeychainFailedError()
            }
            guard let shortFormIssuerDID = try await Identus.shared.didShortForm(from: issuerDID) else {
                print("Could not get short form DID from keychain!")
                throw RegisterGetDIDShortFormFailedError()
            }
            guard try await Identus.shared.verifyIssuerDIDIsPublished(shortOrLongFormDID: shortFormIssuerDID.string) else
            {
                print("Issuer DID is not yet Published!")
                throw RegisterVerifyIssuerDIDIsPublishedError()
            }
            // Get Passport SchemaId
            guard let passportSchemaId = Identus.shared.readPassportSchemaIdFromKeychain() else {
                print("Could not read Passport Schema ID from keychain!")
                throw RegisterReadPassportSchemaIDFromKeychainError()
            }
            
            // Get ConnectionId
            guard let currentConnectionId = Identus.shared.readConnectionIdFromKeychain() else {
                print("Could not read Connection ID from keychain!")
                throw RegisterConnectionIDFromKeychainError()
            }
            
            let credentialOffer = try await Identus.shared.createPassportCredentialOffer(request: CreateCredentialOfferRequest(
                validityPeriod: 3600,
                schemaId: "http://localhost:8085/schema-registry/schemas/\(passportSchemaId)/schema", // TODO: make this baseURL dynamic.  it's very important to be THIS baseURL, Cloud Agent can't dereference it from Docker if's different.  This should only be this way for dev.  Prod needs a real live URL
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
                throw RegisterStoreThidInKeychainError()
            }

        } catch {
            print(error)
            throw RegisterCreateCredentialOfferError()
        }
    }
    
    public func requestProof() async throws -> PresentationResponseContent {
        
        guard let passportSchemaId = Identus.shared.readPassportSchemaIdFromKeychain() else {
            throw Identus.PassportFailedToReadFromKeychainError()
        }
        
        do {
            // This creates a Proof Presentation Request
            guard let presentation = try await Identus.shared.createProofRequest(schemaId: passportSchemaId) else {
                throw RegisterCreateProofRequestError()
            }
            return presentation
            
        } catch {
            print(error)
            throw RegisterCreateProofRequestError()
        }
        
        
        // TODO: Fix getPresentations() - for some reason the result doesn't parse
//        do {
//            // Let's check the list of active Proof Presentation Requests
//            let presentationRequestsList = try await Identus.shared.getPresentations()
//            
//            print("List of Presentations is: \(String(describing: presentationRequestsList))")
//        } catch {
//            print(error)
//            throw RegisterGetPresentationsError()
//        }
            
    }
}
