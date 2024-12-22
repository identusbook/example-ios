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
