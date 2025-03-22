//
//  Auth.swift
//  FlightTix
//
//  Created by Jon Bauer on 12/15/24.
//

import Foundation
import EdgeAgentSDK

class Auth: ObservableObject {
    
    // Singleton
    static let shared = Auth()
    private init() {}
    
    private var authValid: Bool = false
    private var agent: EdgeAgent?
    
    public func logout() async throws {
        // Delete or Revoke Passport VC Credential
        authValid = false
    }

    public func isLoggedIn() async -> Bool {
        
        if !authValid {
            do {
                let loginVCExists = try await loginVCExistsAndHasPresentedProof()
                if loginVCExists { authValid = true }
            } catch {
                print(error)
            }
        }
    
        return authValid
    }
    
    private func loginVCExistsAndHasPresentedProof() async throws -> Bool {
        
        // First we will check that the Holder has an expected Credential
        // The Holder will need to present proof that it's valid
        
        // Get Credentials
        var credentials: [Credential]?
        do {
            credentials = try await Identus.shared.fetchCredentials()
        } catch {
            print("Error fetching credentials: \(error)")
        }
        
        // TODO: We will need a way to check that the Holder has a credential of an expected type, not just any credential
        // Until there is a better way to do this, we will need to check for certain claims, or add a type as a Claim
        guard let credentials else { return false }
        for credential: Credential in credentials {
            
            print("Credential is: \(credential)")
            
            // Check for a PassportVC by checking the credentialSchema
            // if credential.verifiableCredential.credentialSchema == knownPassportVCSchemaID { return true }
            
            // if we have a PassportVC, we need the Holder to present proof that it's valid
            
            
            return true
        }
        
        return false
    }
    
    // TODO: Can we enforce a strong Passport type here?
    // TODO: Should this function live somewehre else? A Type specific location?
    private func verifyPassportVC(passportCredential: Credential) async throws {
        
        /*
        The protocol consists of the following main parts:

        The Verifier creates a new proof presentation request using the /present-proof/presentations endpoint. It includes the identifier of an existing connection between both parties, domain, and a challenge to protect from potential replay attacks.
        The Holder/Prover receives the presentation request from the Verifier and can retrieve the list of existing requests using the /present-proof/presentations endpoint.
        The Holder/Prover can then review and accept a specific request using the /present-proof/presentations/{presentationId} endpoint, providing the identifier of the credential record to use in the proof presentation.
        The Verifier receives the proof presentation from the Holder/Prover and can accept it using the /present-proof/presentations/{presentationId} endpoint, specifying presentation-accept as the action type.
        */
        
        /*
         In this example app, we are the Holder, and will start the process by telling the Verifier
         (Cloud Agent) to create a Presentation. In production, some application specific middleware
         would probably trigger this process, not the mobile app of the Holder.
         */
        do {
            let presentation = try await Identus.shared.createProofRequest()
            
            let listOfPresentations = try await Identus.shared.getPresentations()
            
            for presentation: PresentationResponseContent in listOfPresentations {
                print("Presentation: \(presentation)")
                
                // Look for the specific Presentation we want to know about
                if presentation.presentationId == passportCredential.id {
//                    let passportPresentation = try await Identus.shared.getPresentation(presentationId: passportCredential.id)
//                    
//                    // Update/Patch Presentation Record
//                    // Tell the Verifier that we (the Holder) Accept the Presentation Request
//                    // Do we as the Holder do this? Or the Holder only accepts the Request?
//                    let acceptedPresentation = UpdatePresentationProofRequest(action: .presentationAccept,
//                                                                                   proofId: [], anonymousCredentialPresentationRequest: nil,
//                                                                                   claims: [:],
//                                                                                   credentialFormat: "JWT"
//                                                                                   )
//                    
//                    
//                    
//                    let updatedPresentation = try await Identus.shared.updatePresentation(presentationId: passportCredential.id, request: acceptedPresentation)
//                    
//                    print("Accepted Presentation: \(acceptedPresentation)")
                    
                    
                    // Accept Request
                    let updateRequestAcceptRequest = UpdatePresentationProofRequest(action: .requestAccept,
                                                                                   proofId: [passportCredential.id], anonymousCredentialPresentationRequest: nil,
                                                                                   claims: [:],
                                                                                   credentialFormat: "JWT"
                                                                                   )
                    
                    
                    
                    let acceptedRequest = try await Identus.shared.updatePresentation(presentationId: passportCredential.id, request: updateRequestAcceptRequest)
                    
                    print("Accepted Request: \(acceptedRequest)")
                    
                }
            }
            
        } catch {
            throw error
        }
        
    }
}
