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
            do {
                let credentialOffer = try await Identus.shared.createCredentialOffer(request: CreateCredentialOfferRequest(
                                                                                                                           label: "FlightTixiOS-CloudAgent",
                                                                                                                           validityPeriod: 3600,
                                                                                                                           schemaId: "http://localhost/cloud-agent/schema-registry/schemas/d7b2512f-5fc4-4069-b5e0-4a70a7a38273/schema",
                                                                                                                           //credentialDefinitionId: nil, // only for AnonCreds
                                                                                                                           credentialFormat: "JWT",
                                                                                                                           claims: PassportClaims(name: "Jon Bauer",
                                                                                                                                                  did: "1234567890",
                                                                                                                                                  dateOfIssuance: Date(),
                                                                                                                                                  passportNumber: "987654322",
                                                                                                                                                  dob: Date()),
                                                                                                                           automaticIssuance: true,
                                                                                                                           issuingDID: "did:prism:805d004cd8b8abecc9d048e962445e830d5e945fd747dfb2d813b543f3eb9f94",
                                                                                                                           //issuingKid: "kid1",
                                                                                                                           connectionId: "f11d096a-7be4-4711-a8ec-6b5e0f5060c4",
                                                                                                                           goalCode: "issue-vc",
                                                                                                                           goal: "To issue a Passport Verifiable Credential")
                )
                print("We should have created a CreditentialOffer at this point \(String(describing: credentialOffer))")
                
                
                // Get recordId
                
                let recordId = credentialOffer.recordId
                
                do {
                    // look up credential offer http://localhost/cloud-agent/issue-credentials/records
                    let credentialRecord = try await Identus.shared.credentialRecord(recordId: recordId)
                    
                    print("We should have found the Credential Offer in the list \(credentialOffer)")
                    
                    // Holder Accepts offer: http://localhost/cloud-agent/issue-credentials/credential-offers/accept-invitation
                    
                    do {
                        let acceptedCredentialRecord = try await Identus.shared.acceptCredentialOffer(recordId: credentialRecord.recordId,
                                                                                                      request: AcceptCredentialOfferRequest(subjectId: credentialRecord.myDid,
                                                                                                                                            keyId: credentialRecord.myDid))
                        print("We should have accepted the Credential Offer by this point \(credentialOffer)")
                    } catch {
                        print("Accepting the Credential offer failed \(error)")
                    }
                    
                    // We can now list all Credentials in our wallet
                    do {
                        try await Identus.shared.listCredentials()
                    } catch {
                        print(error)
                    }
                    
                    
                } catch {
                    print("Credential Record failed with error: \(error)")
                }
                
                
                
                
            } catch {
                print("CreateCredentialOffer failed with error: \(error)")
                throw error
            }
            
            
            //https://hyperledger.github.io/identus-docs/tutorials/credentials/issue
            //            # Issuer POST request to create a new credential offer
            //            curl -X 'POST' \
            //              'http://localhost:8080/cloud-agent/issue-credentials/credential-offers' \
            //                -H 'accept: application/json' \
            //                -H 'Content-Type: application/json' \
            //                -H "apikey: $API_KEY" \
            //                -d '{
            //                      "claims": {
            //                        "emailAddress": "alice@wonderland.com",
            //                        "givenName": "Alice",
            //                        "familyName": "Wonderland",
            //                        "dateOfIssuance": "2020-11-13T20:20:39+00:00",
            //                        "drivingLicenseID": "12345",
            //                        "drivingClass": 3,
            //                        "exp" : 1883000000
            //                      },
            //                      "credentialFormat": "SDJWT",
            //                      "issuingDID": "did:prism:9f847f8bbb66c112f71d08ab39930d468ccbfe1e0e1d002be53d46c431212c26",
            //                      "connectionId": "9d075518-f97e-4f11-9d10-d7348a7a0fda",
            //                      "schemaId": "http://localhost:8080/cloud-agent/schema-registry/schemas/3f86a73f-5b78-39c7-af77-0c16123fa9c2"
            //                    }'
            
            
            // if VC success, set login status
            try await Auth.shared.login(passport: passport)
        } catch {
            print(error)
        }
    }
}
