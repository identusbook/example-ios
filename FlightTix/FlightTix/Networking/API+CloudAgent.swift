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
        
        func acceptCredentialOffer(recordId: String, request: AcceptCredentialOfferRequest) async throws -> CredentialRecordResponse? {
            
            let acceptCredentialOfferBody = request
            let encoder = JSONEncoder()
            guard let bodyData = try? encoder.encode(acceptCredentialOfferBody) else { return nil }
            
            let url = URL(string: "\(baseURL)/issue-credentials/records/\(recordId)/accept-offer")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = bodyData
        
            do {
                let response = try await api.handleRequest(request: request)
                guard let data = try await api.dataFromResponse(urlResponse: response.response, data: response.data) else {
                    return nil
                }
                return try JSONDecoder().decode(CredentialRecordResponse.self, from: data)
            } catch {
                throw error
            }
        }
        
        func credentialRecord(recordId: String) async throws -> CredentialRecordResponse? {
            
            let url = URL(string: "\(baseURL)/issue-credentials/records/\(recordId)")!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
          
            do {
                let response = try await api.handleRequest(request: request)
                guard let data = try await api.dataFromResponse(urlResponse: response.response, data: response.data) else {
                    return nil
                }
                return try JSONDecoder().decode(CredentialRecordResponse.self, from: data)
            } catch {
                throw error
            }
        }
        
        func createCredentialOffer(request: CreateCredentialOfferRequest) async throws -> CreateCredentialOfferResponse? {
            
            let createCredentialOfferBody = request
            let encoder = JSONEncoder()
            encoder.outputFormatting = .withoutEscapingSlashes
            guard let bodyData = try? encoder.encode(createCredentialOfferBody) else { return nil }
            
            let url = URL(string: "\(baseURL)/issue-credentials/credential-offers")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = bodyData
        
            do {
                let response = try await api.handleRequest(request: request)
                guard let data = try await api.dataFromResponse(urlResponse: response.response, data: response.data) else {
                    return nil
                }
                return try JSONDecoder().decode(CreateCredentialOfferResponse.self, from: data)
            } catch {
                throw error
            }
        }
        
        func createInvitation() async throws -> CreateInvitationResponse? {
            
            let createInvitationBody = CreateInvitationRequest(label: IdentusConfig().cloudAgentConnectionLabel)
            let encoder = JSONEncoder()
            guard let bodyData = try? encoder.encode(createInvitationBody) else { return nil }
            
            let url = URL(string: "\(baseURL)/connections")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = bodyData
        
            do {
                let response = try await api.handleRequest(request: request)
                guard let data = try await api.dataFromResponse(urlResponse: response.response, data: response.data) else {
                    return nil
                }
                return try JSONDecoder().decode(CreateInvitationResponse.self, from: data)
            } catch {
                throw error
            }
        }
        
        func getConnections() async throws -> ConnectionResponse? {
            
            let url = URL(string: "\(baseURL)/connections")!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
          
            do {
                let response = try await api.handleRequest(request: request)
                guard let data = try await api.dataFromResponse(urlResponse: response.response, data: response.data) else {
                    return nil
                }
                return try JSONDecoder().decode(ConnectionResponse.self, from: data)
            } catch {
                throw error
            }
        }
        
        func createIssuerDID(request: CreateDIDRequest) async throws -> CreateDIDResponse? {
            
            let createDIDBody = request
            let encoder = JSONEncoder()
            encoder.outputFormatting = .withoutEscapingSlashes
            guard let bodyData = try? encoder.encode(createDIDBody) else { return nil }
            
            let url = URL(string: "\(baseURL)/did-registrar/dids")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = bodyData
        
            do {
                let response = try await api.handleRequest(request: request)
                guard let data = try await api.dataFromResponse(urlResponse: response.response, data: response.data) else {
                    return nil
                }
                return try JSONDecoder().decode(CreateDIDResponse.self, from: data)
            } catch {
                throw error
            }
        }
        
        func didsOnCloudAgent() async throws -> DIDsOnCloudAgentResponse? {
            
            let url = URL(string: "\(baseURL)/did-registrar/dids")!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
          
            do {
                let response = try await api.handleRequest(request: request)
                guard let data = try await api.dataFromResponse(urlResponse: response.response, data: response.data) else {
                    return nil
                }
                return try JSONDecoder().decode(DIDsOnCloudAgentResponse.self, from: data)
            } catch {
                throw error
            }
        }
        
        func didStatus(shortOrLongFormDID: String) async throws -> DIDStatusResponse? {
            
            let url = URL(string: "\(baseURL)/did-registrar/dids/\(shortOrLongFormDID)")!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
          
            do {
                let response = try await api.handleRequest(request: request)
                guard let data = try await api.dataFromResponse(urlResponse: response.response, data: response.data) else {
                    return nil
                }
                return try JSONDecoder().decode(DIDStatusResponse.self, from: data)
            } catch {
                throw error
            }
        }
        
        func requestDIDPublication(request: PublishDIDRequest) async throws -> PublishDIDResponse? {
            
            let publishDIDBody = request
            let encoder = JSONEncoder()
            encoder.outputFormatting = .withoutEscapingSlashes
            guard let bodyData = try? encoder.encode(publishDIDBody) else { return nil }
            
            let url = URL(string: "\(baseURL)/did-registrar/dids/\(request.didRef)/publications")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = bodyData
        
            do {
                let response = try await api.handleRequest(request: request)
                guard let data = try await api.dataFromResponse(urlResponse: response.response, data: response.data) else {
                    return nil
                }
                return try JSONDecoder().decode(PublishDIDResponse.self, from: data)
            } catch {
                throw error
            }
        }
    }
    
    var cloudAgent: CloudAgent {
        CloudAgent(api: self)
    }
}
