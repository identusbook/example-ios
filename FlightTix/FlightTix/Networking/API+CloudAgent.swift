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
