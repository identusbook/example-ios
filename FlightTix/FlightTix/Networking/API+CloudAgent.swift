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
                
                print("reponse is \(response)")
                
                guard let data = try await api.dataFromResponse(urlResponse: response.response, data: response.data) else {
                    return nil
                }
                
                let decoder = JSONDecoder()
                let decodedResponse = try decoder.decode(CredentialRecordResponse.self, from: data)
                
                print("decoded reponse is \(decodedResponse)")
                return decodedResponse
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
                
                print("reponse is \(response)")
                
                guard let data = try await api.dataFromResponse(urlResponse: response.response, data: response.data) else {
                    return nil
                }
                
                let decoder = JSONDecoder()
                let decodedResponse =  try decoder.decode(CredentialRecordResponse.self, from: data)
                
                print("decoded reponse is \(decodedResponse)")
                return decodedResponse
            } catch {
                throw error
            }
        }
        
        func createCredentialOffer(request: CreateCredentialOfferRequest) async throws -> CreateCredentialOfferResponse? {
            
            let createCredentialOfferBody = request
            let encoder = JSONEncoder()
            guard let bodyData = try? encoder.encode(createCredentialOfferBody) else { return nil }
            
            let url = URL(string: "\(baseURL)/issue-credentials/credential-offers")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = bodyData
        
            do {
                let response = try await api.handleRequest(request: request)
                
                print("reponse is \(response)")
                
                guard let data = try await api.dataFromResponse(urlResponse: response.response, data: response.data) else {
                    return nil
                }
                
                let decoder = JSONDecoder()
                let decodedResponse = try decoder.decode(CreateCredentialOfferResponse.self, from: data)
                
                print("decoded reponse is \(decodedResponse)")
                return decodedResponse
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
                
                print("reponse is \(response)")
                
                guard let data = try await api.dataFromResponse(urlResponse: response.response, data: response.data) else {
                    return nil
                }
                
                let decoder = JSONDecoder()
                let decodedResponse = try decoder.decode(CreateInvitationResponse.self, from: data)
                
                print("decoded reponse is \(decodedResponse)")
                return decodedResponse
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
                
                print("reponse is \(response)")
                
                guard let data = try await api.dataFromResponse(urlResponse: response.response, data: response.data) else {
                    return nil
                }
                
                let decoder = JSONDecoder()
                let decodedResponse =  try decoder.decode(ConnectionResponse.self, from: data)
                
                print("decoded reponse is \(decodedResponse)")
                return decodedResponse
            } catch {
                throw error
            }
        }
    }
    
    var cloudAgent: CloudAgent {
        CloudAgent(api: self)
    }
}
