//
//  ProfileViewModel.swift
//  FlightTix
//
//  Created by Jon Bauer on 7/11/25.
//

import Foundation
import EdgeAgentSDK

class ProfileViewModel: ObservableObject {
    
    final class CanNotReadPassportSchemaError: Error {}
    final class CanNotFindPassportCredentialError: Error {}
    final class CanNotGetPassportDetailsError: Error {}

    @Published var isLoading: Bool = false
    
    @Published var traveller: Traveller?
    
    @Published var error: Error?
    
    func getTraveller() async throws {
        let traveller = try await getPassportDetails()
        Task { @MainActor in
            self.traveller = traveller
        }
    }
    
    func getPassportDetails() async throws -> Traveller {
        guard let passportSchemaID = Identus.shared.readPassportSchemaIdFromKeychain() else {
            throw CanNotReadPassportSchemaError()
        }
        guard let cred = try await Identus.shared.fetchCredential(ofSchema: passportSchemaID) else {
            throw CanNotFindPassportCredentialError()
        }
        
        let claimValues = populateProfileClaims(claims: cred.claims)
        
        let traveller = Traveller(
            passport: Passport(name: claimValues.name ?? "",
                               did: claimValues.did ?? "",
                               passportNumber: claimValues.passportNumber ?? "",
                               dob: Date().stringToDate(iso8601String: claimValues.dob ?? "") ?? Date(),
                               dateOfIssuance: Date().stringToDate(iso8601String: claimValues.dateOfIssuance ?? "") ?? Date())
        )
        return traveller
    }
    
    private func populateProfileClaims(claims: [Claim]) -> (name: String?, passportNumber: String?, did: String?, dob: String?, dateOfIssuance: String?) {
        var name: String?
        var did: String?
        var passportNumber: String?
        var dob: String?
        var dateOfIssuance: String?
        for claim in claims {
            if claim.key == "name" {
                name = claim.getValueAsString()
            }
            if claim.key == "did" {
                did = claim.getValueAsString()
            }
            if claim.key == "passportNumber" {
                passportNumber = claim.getValueAsString()
            }
            if claim.key == "dob" {
                let dobString = claim.getValueAsString()
                let prettyDOB = DateStuff.displayISODateAsString(dobString, showTime: false)
                dob = prettyDOB
            }
            if claim.key == "dateOfIssuance" {
                //dateOfIssuance = claim.getValueAsString()
                let doiString = claim.getValueAsString()
                let prettyDOi = DateStuff.displayISODateAsString(doiString, showTime: false)
                dateOfIssuance = prettyDOi
            }
        }
        return (name, passportNumber, did, dob, dateOfIssuance)
    }
}
