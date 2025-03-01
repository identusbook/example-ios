//
//  API+CloudAgent.swift
//  FlightTix
//
//  Created by Jon Bauer on 12/22/24.
//

import Foundation

extension APIClient {
    
    final class CredentialOfferResponseDecodeError: Error {}
    
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
        
        func createPassportCredentialOffer(request: CreateCredentialOfferRequest) async throws -> CreateCredentialOfferResponse? {
            
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
                do {
                    let credentialOfferRresponse = try JSONDecoder().decode(CreateCredentialOfferResponse.self, from: data)
                    return credentialOfferRresponse
                } catch {
                    throw CredentialOfferResponseDecodeError()
                }
                
            } catch {
                throw error
            }
        }
        
        func createTicketCredentialOffer(request: CreateTicketCredentialOfferRequest) async throws -> CreateTicketCredentialOfferResponse? {
            
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
                do {
                    let credentialOfferRresponse = try JSONDecoder().decode(CreateTicketCredentialOfferResponse.self, from: data)
                    return credentialOfferRresponse
                } catch {
                    throw CredentialOfferResponseDecodeError()
                }
                
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
        
        func createPassportSchema(schema: PassportSchema) async throws -> PassportSchema? {
            
            let createSchemaBody = schema
            let encoder = JSONEncoder()
            encoder.outputFormatting = .withoutEscapingSlashes
            guard let bodyData = try? encoder.encode(createSchemaBody) else { return nil }
            
            let url = URL(string: "\(baseURL)/schema-registry/schemas")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = bodyData
        
            do {
                let response = try await api.handleRequest(request: request)
                guard let data = try await api.dataFromResponse(urlResponse: response.response, data: response.data) else {
                    return nil
                }
                return try JSONDecoder().decode(PassportSchema.self, from: data)
            } catch {
                throw error
            }
        }
        
        func createTicketSchema(schema: TicketSchema) async throws -> TicketSchema? {
            
            let createSchemaBody = schema
            let encoder = JSONEncoder()
            encoder.outputFormatting = .withoutEscapingSlashes
            guard let bodyData = try? encoder.encode(createSchemaBody) else { return nil }
            
            let url = URL(string: "\(baseURL)/schema-registry/schemas")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = bodyData
        
            do {
                let response = try await api.handleRequest(request: request)
                guard let data = try await api.dataFromResponse(urlResponse: response.response, data: response.data) else {
                    return nil
                }
                return try JSONDecoder().decode(TicketSchema.self, from: data)
            } catch {
                throw error
            }
        }
        
        func getPassportSchemaByGuid(guid: String) async throws -> PassportSchema? {
            
            let url = URL(string: "\(baseURL)/schema-registry/schemas/\(guid)")!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
          
            do {
                let response = try await api.handleRequest(request: request)
                guard let data = try await api.dataFromResponse(urlResponse: response.response, data: response.data) else {
                    return nil
                }
                return try JSONDecoder().decode(PassportSchema.self, from: data)
            } catch {
                throw error
            }
        }
        
        func getTicketSchemaByGuid(guid: String) async throws -> TicketSchema? {
            
            let url = URL(string: "\(baseURL)/schema-registry/schemas/\(guid)")!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
          
            do {
                let response = try await api.handleRequest(request: request)
                guard let data = try await api.dataFromResponse(urlResponse: response.response, data: response.data) else {
                    return nil
                }
                return try JSONDecoder().decode(TicketSchema.self, from: data)
            } catch {
                throw error
            }
        }
        
        // Present Proof
        func getPresentations() async throws -> PresentationsResponse? {
            
            let url = URL(string: "\(baseURL)/present-proof/presentations")!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
          
            do {
                let response = try await api.handleRequest(request: request)
                guard let data = try await api.dataFromResponse(urlResponse: response.response, data: response.data) else {
                    return nil
                }
                return try JSONDecoder().decode(PresentationsResponse.self, from: data)
            } catch {
                throw error
            }
        }
        
        func getProofPresentationRecord(presentationId: String) async throws -> PresentationResponseContent? {
            
            let url = URL(string: "\(baseURL)/present-proof/presentations/\(presentationId)")!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
          
            do {
                let response = try await api.handleRequest(request: request)
                guard let data = try await api.dataFromResponse(urlResponse: response.response, data: response.data) else {
                    return nil
                }
                return try JSONDecoder().decode(PresentationResponseContent.self, from: data)
            } catch {
                throw error
            }
        }
        
        func createProofPresentation(request: CreateProofPresentationRequest) async throws -> PresentationsResponse? {
            
            let requestBody = request
            let encoder = JSONEncoder()
            encoder.outputFormatting = .withoutEscapingSlashes
            guard let bodyData = try? encoder.encode(requestBody) else { return nil }
            
            let url = URL(string: "\(baseURL)/present-proof/presentations")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = bodyData
        
            do {
                let response = try await api.handleRequest(request: request)
                guard let data = try await api.dataFromResponse(urlResponse: response.response, data: response.data) else {
                    return nil
                }
                return try JSONDecoder().decode(PresentationsResponse.self, from: data)
            } catch {
                throw error
            }
        }
        
        func acceptPresentationProof(presentationId: String, request: AcceptPresentationProofRequest) async throws -> PresentationsResponse? {
            
            let requestBody = request
            let encoder = JSONEncoder()
            encoder.outputFormatting = .withoutEscapingSlashes
            guard let bodyData = try? encoder.encode(requestBody) else { return nil }
            
            let url = URL(string: "\(baseURL)/present-proof/presentations/\(presentationId)")!
            var request = URLRequest(url: url)
            request.httpMethod = "PATCH"
            request.httpBody = bodyData
        
            do {
                let response = try await api.handleRequest(request: request)
                guard let data = try await api.dataFromResponse(urlResponse: response.response, data: response.data) else {
                    return nil
                }
                return try JSONDecoder().decode(PresentationsResponse.self, from: data)
            } catch {
                throw error
            }
        }
        
        // Verifiable Credentials Verification
        func verifyCredential(request: VerifyCredentialRequest) async throws -> VerifyCredentialResponse? {
            
            let requestBody = request
            let encoder = JSONEncoder()
            encoder.outputFormatting = .withoutEscapingSlashes
            guard let bodyData = try? encoder.encode(requestBody) else { return nil }
            
            let url = URL(string: "\(baseURL)/verification/credential")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = bodyData
        
            do {
                let response = try await api.handleRequest(request: request)
                guard let data = try await api.dataFromResponse(urlResponse: response.response, data: response.data) else {
                    return nil
                }
                return try JSONDecoder().decode(VerifyCredentialResponse.self, from: data)
            } catch {
                throw error
            }
        }
    }
    
    var cloudAgent: CloudAgent {
        CloudAgent(api: self)
    }
}
