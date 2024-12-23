//
//  Identus.swift
//  FlightTix
//
//  Created by Jon Bauer on 12/15/24.
//

import Combine
import Foundation
import EdgeAgentSDK
import KeychainSwift

final class Identus: ObservableObject {
    
    final class SeedFailedToSaveToKeychainError: Error {}
    final class SeedKeychainKeyNotPresentError: Error {}
    final class SeedFailedToDeleteFromKeychainError: Error {}
    
    // Config
    let mediatorOOBURL: URL
    let mediatorDID: DID
    let seedKeychainKey: String
    let urlSessionConfig: URLSessionConfig
    
    @Published var agentRunning = false
    
    //private var edgeAgent: EdgeAgent
    private var didCommAgent: DIDCommAgent?
    @Published var status: String = ""
    @Published var error: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    init(config: IdentusConfig) throws {
        mediatorOOBURL = URL(string: config.mediatorOOBString)!
        mediatorDID = try! DID(string: config.mediatorDidString)
        seedKeychainKey = config.seedKeychainKey
        urlSessionConfig = config.urlSessionConfig
    }
    
    public func createInvitation() async throws -> OutOfBandInvitation? {
        let networkActor = APIClient(configuration: FlightTixURLSession(mode: .development, config: urlSessionConfig as! FlightTixSessionConfigStruct))
        do {
            guard let invitation = try await networkActor.cloudAgent.createInvitation() else { return nil }
            return try await parseCloudAgentOOBMessage(invitation: invitation)
        } catch {
            throw error
        }
    }
    
    private func parseCloudAgentOOBMessage(invitation: CreateInvitationResponse) async throws -> OutOfBandInvitation? {
        
        let oobURLFromCloudAgent = URL(string: invitation.invitation.invitationUrl)!
        
        do {
            return try didCommAgent?.parseOOBInvitation(url: oobURLFromCloudAgent)
        } catch let error as CommonError {
            switch error {
            case let .httpError(_, message):
                print("Error: \(message)")
            default:
                break
            }
        } catch let error as LocalizedError {
            print("Error: \(String(describing: error.errorDescription))")
        }
        return nil
    }
    
    public func acceptDIDCommInvite(invitationFromCloudAgent: OutOfBandInvitation) async throws {
        
        do {
            print("Attempt to accept Cloud Agent Invitation")
            try await didCommAgent?.acceptDIDCommInvitation(invitation: invitationFromCloudAgent)
            print("we should have accepted the invitation")

        } catch let error as CommonError {
            switch error {
            case let .httpError(_, message):
                print("Error: \(message)")
            default:
                break
            }
        } catch let error as LocalizedError {
            print("Error: \(String(describing: error.errorDescription))")
        }
        
    }
    
    func start() async throws {
        await MainActor.run {
            status = didCommAgent?.state.rawValue ?? "Status Not Available - didComAgent is nil"
        }
        do {
            
            if let seed = seedExists(key: seedKeychainKey) {
                self.didCommAgent = DIDCommAgent(seedData: seed.value, mediatorDID: mediatorDID)
            } else {
                let seed = try await generateSeed()
                self.didCommAgent = DIDCommAgent(seedData: seed.value, mediatorDID: mediatorDID)
            }
            
            status = didCommAgent?.state.rawValue ?? "Status Not Available - didComAgent is nil"
            
            try await didCommAgent?.start()
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
            }
        }
        await MainActor.run {
            status = didCommAgent?.state.rawValue ?? "Status Not Available - didComAgent is nil"
        }
    }
    
    private func seedExists(key: String) -> Seed? {
        let keychain = KeychainSwift()
        if let seedData = keychain.getData(key) {
            return Seed(value: seedData)
        }
        return nil
    }
    
    private func generateSeed() async throws -> Seed {
        let apollo = ApolloImpl()
        // create Random Seed for demo purposes
        let (_, seed) = apollo.createRandomSeed()
        
        // Store new Seed in Keychain
        let keychain = KeychainSwift()
        keychain.set(seed.value, forKey: seedKeychainKey)
        if keychain.lastResultCode != noErr {
            throw SeedFailedToSaveToKeychainError()
        }
        if let seed = seedExists(key: seedKeychainKey) {
            return seed
        }
        throw SeedFailedToSaveToKeychainError()
    }
    
    private func deleteSeedFromKeychain() -> Bool {
        let keychain = KeychainSwift()
        return keychain.delete(seedKeychainKey) ? true : false
    }
    
    // Meant mostly for testing during development
    // Cleans up Agent and related artifacts
    public func tearDown() async throws {
        do {
            try await didCommAgent?.stop()
            guard deleteSeedFromKeychain() else { throw SeedFailedToDeleteFromKeychainError() }
            print("Identus has been torn down")
        } catch {
            throw error
        }
    }
    
    @MainActor
    func startMessageStream() {
        didCommAgent?.startFetchingMessages()
        didCommAgent?.handleReceivedMessagesEvents().sink {
            switch $0 {
            case .finished:
                print("Finished message retrieval")
            case .failure(let error):
                self.error = error.localizedDescription
            }
        } receiveValue: { message -> () in
            
            //print("Message is: \(message)")
            
            if let connectionAccept = try? ConnectionAccept(fromMessage: message) {
                print("ConnectionAccept: \(connectionAccept)")
                // Store connectionId
                // Or can get this info from the wallet anytime via Pluto
            }
            
            if let connectionRequest = try? ConnectionRequest(fromMessage: message) {
                print("ConnectionRequest: \(connectionRequest)")
            }
            
            if let reportProblem = try? ReportProblemMessage(fromMessage: message) {
                print("ReportProblem: \(reportProblem)")
            }
            
            if let basicMessage = try? BasicMessage(fromMessage: message) {
                print("BasicMessage: \(basicMessage)")
            }
            
            if let offerCredential = try? OfferCredential(fromMessage: message) {
                //OfferCredential will get sent when I ask for a VC
                // Accept this offer (or have UI for user to accept it) via REST: https://hyperledger.github.io/identus-docs/tutorials/credentials/issue#receiving-the-vc-offer
                print("OfferCredential: \(offerCredential)")
            }
            
            //
            
//            guard message.type == ProtocolTypes.didcomminvitation.rawValue else {
//                throw EdgeAgentError.unknownInvitationTypeError
//            }
            
            do {
                if let issued = try? IssueCredential(fromMessage: message) {
                    
                    print("Issued: \(issued)")
                    
                    _ = try issued.attachments.compactMap {
                        switch $0.data {
                        case let data as AttachmentBase64:
                            break
                        default:
                            return
                        }
                    }
                }
            } catch {
                print(error)
            }
        }
        .store(in: &cancellables)
    }
    
    public func connectionExists(connectionId: String, label: String?) async throws -> Bool {
        let networkActor = APIClient(configuration: FlightTixURLSession(mode: .development, config: urlSessionConfig as! FlightTixSessionConfigStruct))
        do {
            guard let connections = try await networkActor.cloudAgent.getConnections() else {
                return false
            }
            return connections.contents.contains(where: { $0.connectionId == connectionId || $0.label == label })
        } catch {
            throw error
        }
    }
}
