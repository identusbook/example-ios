//
//  RegisterViewModel.swift
//  FlightTix
//
//  Created by Jon Bauer on 12/20/24.
//

import Foundation

class RegisterViewModel: ObservableObject {
    
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
            guard let issuerDID = Identus.shared.readIssuerDIDFromKeychain() else { return }
            guard let shortFormIssuerDID = try await Identus.shared.didShortForm(from: issuerDID) else { return }
            guard try await Identus.shared.verifyIssuerDIDIsPublished(shortOrLongFormDID: shortFormIssuerDID.string) else { return }
            
            // Get ConnectionId
            guard let currentConnectionId = Identus.shared.readConnectionIdFromKeychain() else { return }
            
            // Create unique goalCode we can use to track the response over DIDComm
            let uniqueGoalCode = "\(UUID().uuidString.lowercased())"
            
            guard Identus.shared.storePassportVCGoalCodeInKeychain(goalCode: uniqueGoalCode) else { return }
            
            do {
                let credentialOffer = try await Identus.shared.createCredentialOffer(request: CreateCredentialOfferRequest(
                    validityPeriod: 3600,
                    credentialFormat: "JWT",
                    claims: PassportClaimsRequest(name: passport.name,
                                                  dateOfIssuance: Date.now.iso8601String(),
                                                  passportNumber: passport.passportNumber,
                                                  dob: passport.dob.iso8601String()),
                    automaticIssuance: true,
                    issuingDID: shortFormIssuerDID.string,
                    connectionId: currentConnectionId,
                    goalCode: uniqueGoalCode,
                    goal: "To issue a Passport Verifiable Credential")
                )
                print("We should have created a CreditentialOffer at this point \(String(describing: credentialOffer))")
               
                } catch {
                    print("Credential Record failed with error: \(error)")
                }

            // if VC success, set login status
            try await Auth.shared.login(passport: passport)
        } catch {
            print(error)
        }
    }
}
