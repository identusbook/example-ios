//
//  API+CloudAgent.swift
//  FlightTix
//
//  Created by Jon Bauer on 12/22/24.
//

import Foundation

extension APIClient {
    
    struct CloudAgent {
        
        var api: APIClient
        var baseURL: URL {
            api.baseURL
        }
        
        func getConnections() async throws -> ConnectionResponse? {
            let url = URL(string: "\(baseURL)/connections")!
            return try await get(url: url)
        }

        func acceptCredentialOffer(recordId: String, request: AcceptCredentialOfferRequest) async throws -> CredentialRecordResponse? {
            let url = URL(string: "\(baseURL)/issue-credentials/records/\(recordId)/accept-offer")!
            return try await post(url: url, requestBody: request)
        }
        
        func credentialRecord(recordId: String) async throws -> CredentialRecordResponse? {
            let url = URL(string: "\(baseURL)/issue-credentials/records/\(recordId)")!
            return try await get(url: url)
        }
        
        func createPassportCredentialOffer(request: CreateCredentialOfferRequest) async throws -> CreateCredentialOfferResponse? {
            let url = URL(string: "\(baseURL)/issue-credentials/credential-offers")!
            return try await postWithoutEscapingSlashes(url: url, request: request)
        }
        
        func createTicketCredentialOffer(request: CreateTicketCredentialOfferRequest) async throws -> CreateTicketCredentialOfferResponse? {
            let url = URL(string: "\(baseURL)/issue-credentials/credential-offers")!
            return try await postWithoutEscapingSlashes(url: url, request: request)
        }
        
        func createInvitation() async throws -> CreateInvitationResponse? {
            
            let request = CreateInvitationRequest(label: IdentusConfig().cloudAgentConnectionLabel)
            let url = URL(string: "\(baseURL)/connections")!
            
            return try await post(url: url, requestBody: request)
        }
      
        func createIssuerDID(request: CreateDIDRequest) async throws -> CreateDIDResponse? {
            let url = URL(string: "\(baseURL)/did-registrar/dids")!
            return try await post(url: url, requestBody: request)
        }
      
        func didsOnCloudAgent() async throws -> DIDsOnCloudAgentResponse? {
            let url = URL(string: "\(baseURL)/did-registrar/dids")!
            return try await get(url: url)
        }
       
        func didStatus(shortOrLongFormDID: String) async throws -> DIDStatusResponse? {
            let url = URL(string: "\(baseURL)/did-registrar/dids/\(shortOrLongFormDID)")!
            return try await get(url: url)
        }
       
        func requestDIDPublication(request: PublishDIDRequest) async throws -> PublishDIDResponse? {
            let url = URL(string: "\(baseURL)/did-registrar/dids/\(request.didRef)/publications")!
            return try await postWithoutEscapingSlashes(url: url, request: request)
        }
       
        func createPassportSchema(schema: PassportSchema) async throws -> PassportSchema? {
            let url = URL(string: "\(baseURL)/schema-registry/schemas")!
            return try await postWithoutEscapingSlashes(url: url, request: schema)
        }
       
        func createTicketSchema(schema: TicketSchema) async throws -> TicketSchema? {
            let url = URL(string: "\(baseURL)/schema-registry/schemas")!
            return try await postWithoutEscapingSlashes(url: url, request: schema)
        }
       
        func getPassportSchemaByGuid(guid: String) async throws -> PassportSchema? {
            let url = URL(string: "\(baseURL)/schema-registry/schemas/\(guid)")!
            return try await get(url: url)
        }
       
        func getTicketSchemaByGuid(guid: String) async throws -> TicketSchema? {
            let url = URL(string: "\(baseURL)/schema-registry/schemas/\(guid)")!
            return try await get(url: url)
        }
       
        // Present Proof
        func getPresentations() async throws -> PresentationsResponse {
            let url = URL(string: "\(baseURL)/present-proof/presentations")!
            return try await getNonOptional(url: url)
        }
        
        func getProofPresentationRecord(presentationId: String) async throws -> PresentationResponseContent? {
            let url = URL(string: "\(baseURL)/present-proof/presentations/\(presentationId)")!
            return try await get(url: url)
        }
       
        func createProofPresentation(request: CreateProofPresentationRequest) async throws -> PresentationResponseContent? {
            let url = URL(string: "\(baseURL)/present-proof/presentations")!
            return try await postWithoutEscapingSlashes(url: url, request: request)
        }
       
        func acceptPresentationProof(presentationId: String, request: AcceptPresentationProofRequest) async throws -> PresentationsResponse? {
            let url = URL(string: "\(baseURL)/present-proof/presentations/\(presentationId)")!
            return try await patch(url: url, request: request)
        }
        
        // Verifiable Credentials Verification
        func verifyCredential(request: VerifyCredentialRequest) async throws -> VerifyCredentialResponse? {
            let url = URL(string: "\(baseURL)/verification/credential")!
            return try await postWithoutEscapingSlashes(url: url, request: request)
        }
    }
    
    var cloudAgent: CloudAgent {
        CloudAgent(api: self)
    }
}

extension APIClient.CloudAgent {
    
    final class DecodeError: Error {}
    final class GetError: Error {}
    final class PostError: Error {}
    final class PatchError: Error {}
    
    func get<T>(url: URL) async throws -> T? where T:Decodable {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
      
        do {
            let response = try await api.handleRequest(request: request)
            guard let data = try await api.dataFromResponse(urlResponse: response.response, data: response.data) else {
                throw DecodeError()
            }
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw GetError()
        }
    }
    
    func getNonOptional<T>(url: URL) async throws -> T where T:Decodable {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
      
        //do {
            let response = try await api.handleRequest(request: request)
            guard let data = try await api.dataFromResponse(urlResponse: response.response, data: response.data) else {
                throw DecodeError()
            }
            
            if let decoded = try? JSONDecoder().decode(T.self, from: data) {
                print("decoded: \(decoded)")
            }
            
            return try JSONDecoder().decode(T.self, from: data)
//        } catch {
//            throw GetError()
//        }
    }
    
    func post<T,R>(url: URL, requestBody: R) async throws -> T? where T:Decodable, R:Encodable {
        let encoder = JSONEncoder()
        guard let bodyData = try? encoder.encode(requestBody) else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = bodyData
      
        do {
            let response = try await api.handleRequest(request: request)
            guard let data = try await api.dataFromResponse(urlResponse: response.response, data: response.data) else {
                throw DecodeError()
            }
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw PostError()
        }
    }
    
    func postWithoutEscapingSlashes<T,R>(url: URL, request: R) async throws -> T? where T:Decodable, R:Encodable {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .withoutEscapingSlashes
  
        guard let bodyData = try? encoder.encode(request) else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = bodyData
      
        do {
            let response = try await api.handleRequest(request: request)
            guard let data = try await api.dataFromResponse(urlResponse: response.response, data: response.data) else {
                throw DecodeError()
            }
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw PostError()
        }
    }
    
    func patch<T,R>(url: URL, request: R) async throws -> T? where T:Decodable, R:Encodable {
        let encoder = JSONEncoder()
        guard let bodyData = try? encoder.encode(request) else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.httpBody = bodyData
      
        do {
            let response = try await api.handleRequest(request: request)
            guard let data = try await api.dataFromResponse(urlResponse: response.response, data: response.data) else {
                throw DecodeError()
            }
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw PatchError()
        }
    }
}
