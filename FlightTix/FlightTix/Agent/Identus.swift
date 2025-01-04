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
    
    // Exception Types
    final class SeedFailedToSaveToKeychainError: Error {}
    final class SeedKeychainKeyNotPresentError: Error {}
    final class SeedFailedToDeleteFromKeychainError: Error {}
    final class ConnectionFailedToDeleteFromKeychainError: Error {}
    final class CredentialOfferRequestFailedError: Error {}
    final class CredentialRecordResponseFailedError: Error {}
    final class AcceptCredentialOfferFailedError: Error {}
    final class CreateIssuerDIDError: Error {}
    final class RequestIssuerDIDToBePublishedError: Error {}
    
    final class IssuerDIDFailedToSaveToKeychainError: Error {}
    final class IssuerDIDKeychainKeyNotPresentError: Error {}
    final class IssuerDIDFailedToDeleteFromKeychainError: Error {}
    
    // Config
    let mediatorOOBURL: URL
    let mediatorDID: DID
    let seedKeychainKey: String
    let cloudAgentConnectionIdKeychainKey: String
    let cloudAgentConnectionLabel: String
    let cloudAgentIssuerDIDKeychainKey: String
    let urlSessionConfig: URLSessionConfig
    
    // DIDComm Agent
    private var didCommAgent: DIDCommAgent?
    
    // Observable Properties
    @Published var status: String = ""
    @Published var error: String?
    
    // Combine
    private var cancellables = Set<AnyCancellable>()
    
    // Singleton Configuration
    private static var config: IdentusConfig?
    class func setup(_ config: IdentusConfig){
        Identus.config = config
    }
    
    // Singleton Init with Configuration
    static var shared: Identus = Identus(config: IdentusConfig())
    private init(config: IdentusConfig) {
        
        guard let config = Identus.config else { fatalError("Identus config not set. Must call Identus.setup(IdentusConfig()) before first use.") }
        
        mediatorOOBURL = URL(string: config.mediatorOOBString)!
        mediatorDID = try! DID(string: config.mediatorDidString)
        seedKeychainKey = config.seedKeychainKey
        cloudAgentConnectionIdKeychainKey = config.cloudAgentConnectionIdKeychainKey
        cloudAgentIssuerDIDKeychainKey = config.cloudAgentIssuerDIDKeychainKey
        cloudAgentConnectionLabel = config.cloudAgentConnectionLabel
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
    
    public func startUpAndConnect() async throws {
        do {
            // Start DIDCommAgent
            try await start()
            // Start receiving messages from Pluto
            await startMessageStream()
            // Create a Connection to Cloud-Agent if it does not already exist
            try await createConnectionToCloudAgentIfNotExists()
//            // Create Issuer DID on Cloud-Agent if it does not already exist
            try await createIssuerDIDOnCloudAgentIfNotExists()
        } catch {
            throw error
        }

    }
    
    @MainActor
    private func start() async throws {
        status = didCommAgent?.state.rawValue ?? "Status Not Available - didComAgent is nil"
        do {
            if let seed = seedExists(key: seedKeychainKey) {
                print("Seed exists. Starting DIDCommAgent with existing Seed")
                self.didCommAgent = DIDCommAgent(seedData: seed.value, mediatorDID: mediatorDID)
            } else {
                print("Generating Random Seed and starting DIDCommAgent")
                let seed = try await generateSeed()
                self.didCommAgent = DIDCommAgent(seedData: seed.value, mediatorDID: mediatorDID)
            }
            status = didCommAgent?.state.rawValue ?? "Status Not Available - didComAgent is nil"
            try await didCommAgent?.start()
        } catch {
            self.error = error.localizedDescription
        }
        status = didCommAgent?.state.rawValue ?? "Status Not Available - didComAgent is nil"
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
    
    private func storeConnectionIdInKeychain(connectionId: String) -> Bool {
        let keychain = KeychainSwift()
        return keychain.set(connectionId, forKey: cloudAgentConnectionIdKeychainKey)
    }
    
    public func readConnectionIdFromKeychain() -> String? {
        let keychain = KeychainSwift()
        return keychain.get(cloudAgentConnectionIdKeychainKey)
    }
    
    private func deleteConnectionIdFromKeychain() -> Bool {
        let keychain = KeychainSwift()
        return keychain.delete(cloudAgentConnectionIdKeychainKey)
    }
    
    // Meant mostly for testing during development
    // Cleans up Agent and related artifacts
    public func tearDown() async throws {
        do {
            try await didCommAgent?.stop()
            print("DidcommAgent stopped")
            
            guard deleteSeedFromKeychain() else { throw SeedFailedToDeleteFromKeychainError() }
            print("Deleted Seed from Keychain")
            
            guard deleteIssuerDIDFromKeychain() else { throw IssuerDIDFailedToDeleteFromKeychainError() }
            print("Deleted IssuerDID from Keychain")
            
            guard deleteConnectionIdFromKeychain() else { throw ConnectionFailedToDeleteFromKeychainError() }
            print("Deleted ConnectionId from Keychain")
            
            
            
            print("Identus has been torn down")
        } catch {
            throw error
        }
    }
    
    /// - Create Conection to Cloud Agent
    /// If no connection exists between the EdgeAgent and the Cloud-Agent, create one
    private func createConnectionToCloudAgentIfNotExists() async throws {
        
        do {
            // User locally stored connectionId if we have one
            if let connectionIdFromKeychain = Identus.shared.readConnectionIdFromKeychain() {
                // We have a connectionId stored in our Keychain, let's see if that connectionId exists on the Cloud-Agent
                // If it does not, we will create one
                if try await !connectionExists(connectionId: connectionIdFromKeychain,
                                               label: cloudAgentConnectionLabel) {
                    try await askCloudAgentForConnectionInvitationAndAcceptIt()
                }
            } else {
                try await askCloudAgentForConnectionInvitationAndAcceptIt()
            }
        } catch {
            throw error
        }
    }
    
    private func askCloudAgentForConnectionInvitationAndAcceptIt() async throws {
        // Ask Cloud-Agent to create an Invitation and accept it
        do {
            let invitationFromCloudAgent = try await Identus.shared.createInvitation()
            guard let invitationFromCloudAgent else { return }
            try await Identus.shared.acceptDIDCommInvite(invitationFromCloudAgent: invitationFromCloudAgent)
        } catch {
            print(error)
        }
    }
    
    public func getDIDsOnCloudAgent() async throws -> DIDsOnCloudAgentResponse {
        let networkActor = APIClient(configuration: FlightTixURLSession(mode: .development, config: urlSessionConfig as! FlightTixSessionConfigStruct))
        do {
            if let dids = try await networkActor.cloudAgent.didsOnCloudAgent() {
                return dids
            }
        } catch {
            throw error
        }
        throw CreateIssuerDIDError()
    }
    
    public func storeIssuerDIDInKeychain(longFormDID: String) -> Bool {
        let keychain = KeychainSwift()
        let encodedDID = longFormDID.encodeBase64()
        return keychain.set(encodedDID, forKey: cloudAgentIssuerDIDKeychainKey)
    }
    
    public func readIssuerDIDFromKeychain() -> String? {
        let keychain = KeychainSwift()
        guard let encodedIssuerDID = keychain.get(cloudAgentIssuerDIDKeychainKey), let decodedIssuerDID = encodedIssuerDID.decodeBase64() else { return nil }
        return decodedIssuerDID
    }
    
    private func deleteIssuerDIDFromKeychain() -> Bool {
        let keychain = KeychainSwift()
        return keychain.delete(cloudAgentIssuerDIDKeychainKey) ? true : false
    }
    
    public func createIssuerDIDOnCloudAgent(request: CreateDIDRequest) async throws -> CreateDIDResponse {
        let networkActor = APIClient(configuration: FlightTixURLSession(mode: .development, config: urlSessionConfig as! FlightTixSessionConfigStruct))
        do {
            if let createdDID = try await networkActor.cloudAgent.createIssuerDID(request: request) {
                return createdDID
            }
        } catch {
            throw error
        }
        throw CreateIssuerDIDError()
    }
    
    private func createIssuerDIDOnCloudAgentIfNotExists() async throws {
        // Check if the Cloud-Agent DID already exists
        // For this limited example, we are going to assume that there is only one DID on the Cloud-Agent at a time, and that this is the issuer DID
        // We will only attempt to create an Issuer DID if there is no DID present on the Cloud-Agent
        do {
            let didsOnCloudAgent = try await Identus.shared.getDIDsOnCloudAgent()
            guard didsOnCloudAgent.contents.isEmpty else {
                // We already have an Issuer DID on Cloud Agent, do nothing
                print("Cloud-Agent Issuer DID already exists.")
                return
            }
            
            do {
                // Create an Issuer DID on the Cloud-Agent and save it for later
                let createIssuerDIDRequest = CreateDIDRequest(documentTemplate: DocumentTemplate(publicKeys: [
                    DIDPublicKey(id: "auth-1", purpose: "authentication"),
                    DIDPublicKey(id: "issue-1", purpose: "assertionMethod"),
                ], services: []))
                let createDIDResponse = try await Identus.shared.createIssuerDIDOnCloudAgent(request: createIssuerDIDRequest)
                print("Created Issuer DID on Cloud-Agent: \(createDIDResponse.longFormDid)")
                guard Identus.shared.storeIssuerDIDInKeychain(longFormDID: createDIDResponse.longFormDid) != false else {
                    throw Identus.IssuerDIDFailedToSaveToKeychainError()
                }
                // Request new Issuer DID to be published - This will Publish asynchronously in the Cloud-Agent.  Make sure it is PUBLISHED before use
                do {
                    guard try await requestDIDPublication(longFormDID: createDIDResponse.longFormDid) else {
                        throw RequestIssuerDIDToBePublishedError()
                    }
                } catch {
                    throw error
                }
                
            } catch {
                throw error
            }
            
        } catch {
            throw error
        }
    }
    
    private func requestDIDPublication(longFormDID: String) async throws -> Bool {
        // Get ShortForm of DID
        let networkActor = APIClient(configuration: FlightTixURLSession(mode: .development, config: urlSessionConfig as! FlightTixSessionConfigStruct))
        do {
            if let didStatus = try await networkActor.cloudAgent.didStatus(shortOrLongFormDID: longFormDID) {
                return try await requestDIDPublication(shortFormDID: didStatus.did)
            }
        } catch {
            throw error
        }
        return false
    }
    
    private func requestDIDPublication(shortFormDID: String) async throws -> Bool {
        let networkActor = APIClient(configuration: FlightTixURLSession(mode: .development, config: urlSessionConfig as! FlightTixSessionConfigStruct))
        do {
            guard let scheduledOperation = try await networkActor.cloudAgent.requestDIDPublication(request: PublishDIDRequest(didRef: shortFormDID)) else {
                return false
            }
            if scheduledOperation.scheduledOperation.didRef == shortFormDID { return true }
        } catch {
            throw error
        }
        return false
    }
    
    public func verifyIssuerDIDIsPublished(shortOrLongFormDID: String) async throws -> Bool {
        let networkActor = APIClient(configuration: FlightTixURLSession(mode: .development, config: urlSessionConfig as! FlightTixSessionConfigStruct))
        do {
            if let did = try await networkActor.cloudAgent.didStatus(shortOrLongFormDID: shortOrLongFormDID) {
                if did.status == "PUBLISHED" { return true }
                return false
            }
        } catch {
            throw error
        }
        throw CredentialOfferRequestFailedError()
    }
    
    public func didShortForm(from longFormDID: String) async throws -> DID? {
        let networkActor = APIClient(configuration: FlightTixURLSession(mode: .development, config: urlSessionConfig as! FlightTixSessionConfigStruct))
        do {
            if let did = try await networkActor.cloudAgent.didStatus(shortOrLongFormDID: longFormDID) {
                return try DID(string: did.did)
                return nil
            }
        } catch {
            throw error
        }
        throw CredentialOfferRequestFailedError()
    }
    
    public func createCredentialOffer(request: CreateCredentialOfferRequest) async throws -> CreateCredentialOfferResponse {
        let networkActor = APIClient(configuration: FlightTixURLSession(mode: .development, config: urlSessionConfig as! FlightTixSessionConfigStruct))
        do {
            if let offer = try await networkActor.cloudAgent.createCredentialOffer(request: request) {
                print("We created a credential offer!")
                return offer
            }
        } catch {
            throw error
        }
        throw CredentialOfferRequestFailedError()
    }
    
    public func credentialRecord(recordId: String) async throws -> CredentialRecordResponse {
        let networkActor = APIClient(configuration: FlightTixURLSession(mode: .development, config: urlSessionConfig as! FlightTixSessionConfigStruct))
        do {
            if let record = try await networkActor.cloudAgent.credentialRecord(recordId: recordId) {
                print("We found the credential offer record!")
                return record
            }
        } catch {
            throw error
        }
        throw CredentialRecordResponseFailedError()
    }
    
    public func acceptCredentialOffer(recordId: String, request: AcceptCredentialOfferRequest) async throws -> CredentialRecordResponse {
        let networkActor = APIClient(configuration: FlightTixURLSession(mode: .development, config: urlSessionConfig as! FlightTixSessionConfigStruct))
        do {
            if let record = try await networkActor.cloudAgent.acceptCredentialOffer(recordId: recordId, request: request) {
                print("We accepted the credential!")
                return record
            }
        } catch {
            throw error
        }
        throw AcceptCredentialOfferFailedError()
    }
    
    var credentialCancellables = Set<AnyCancellable>() // Store subscriptions to retain them
    public func listCredentials() async throws {
        
        
        self.didCommAgent?.edgeAgent.verifiableCredentials().sink(
            receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("Finished successfully.")
                case .failure(let error):
                    print("Received error: \(error)")
                }
            },
            receiveValue: { value in
                print("-------LIST CREDENTIALS------------")
                print("Received value: \(value)")
                print("-------END LIST CREDENTIALS------------")
            }
        )
        .store(in: &cancellables)
        
        //return credentials ?? []
    }
    
    public func acceptOffer(did: DID, type: String, offerPayload: Data) async throws {
        do {
            try await self.didCommAgent?.edgeAgent.prepareRequestCredentialWithIssuer(did: did, type: type, offerPayload: offerPayload)
        } catch {
            throw error
        }
    }
    
    public func createDID() async throws -> DID? {
        guard let did = try await didCommAgent?.createNewPrismDID(
            // Add this if you want to provide a IndexPath
//            keyPathIndex: 0,
//            // Add this if you want to provide an alias for this DID
//            // alias: T##String?
//            // Add any services available in the DID
//            services: [ .init(
//                id: "DemoID",
//                type: ["DemoType"],
//                serviceEndpoint: [.init(uri: "DemoServiceEndpoint")]
//            )
//            ]
        ) else {
            return nil
        }
        return did
    }
    
    public func validateDID(shortForm: String) throws -> DID {
        do {
            return try DID(string: shortForm)
        } catch {
            throw error
        }
    }
    
    @MainActor
    private func startMessageStream() {
        didCommAgent?.startFetchingMessages()
        didCommAgent?.handleReceivedMessagesEvents().sink {
            switch $0 {
            case .finished:
                print("Finished message retrieval")
            case .failure(let error):
                self.error = error.localizedDescription
            }
        } receiveValue: { message -> () in
            
            guard message.direction == .received,
                  let msgType = ProtocolTypes(rawValue: message.piuri)
            else {
                return
            }
            
//            Task.detached { [weak self] in
//                do {
//                    switch msgType {
////                    case .didcommPresentation:
////                        let presentation = try Presentation(fromMessage: message)
////                    case .didcommRequestPresentation:
////                        let credential = try await agent.edgeAgent.verifiableCredentials().map { $0.first }.first().await()
////                        guard let credential else {
////                            throw UnknownError.somethingWentWrongError()
////                        }
////                        let presentation = try await agent.createPresentationForRequestProof(
////                            request: try RequestPresentation(fromMessage: message),
////                            credential: credential
////                        )
////                        _ = try await agent.sendMessage(message: try presentation.makeMessage())
//                    case .didcommOfferCredential, .didcommOfferCredential3_0:
//                        guard let newPrismDID = try await self?.didCommAgent?.createNewPrismDID() else { return }
//                        guard let requestCredential = try await self?.didCommAgent?.prepareRequestCredentialWithIssuer(
//                            did: newPrismDID,
//                            offer: try OfferCredential3_0(fromMessage: message)
//                        ) else { throw UnknownError.somethingWentWrongError() }
//                        _ = try await self?.didCommAgent?.sendMessage(message: try requestCredential.makeMessage())
//                    case .didcommconnectionRequest:
//                        let request = try ConnectionRequest(fromMessage: message)
//                        let accept = ConnectionAccept(fromRequest: request)
//                        _ = try await self?.didCommAgent?.sendMessage(message: try accept.makeMessage())
//                    default:
//                        break
//                    }
//                } catch let error as LocalizedError {
//                    throw error
//                }
//            }
            
            Task.detached { [weak self] in
                switch msgType {
                case .didcommBasicMessage:
                    print("Basic Message: \(message)")
                case .didcommMediationRequest:
                    print("Mediation Request: \(message)")
                case .didcommMediationGrant:
                    print("Mediation Grant: \(message)")
                case .didcommMediationDeny:
                    print("Mediation Deny: \(message)")
                case .didcommMediationKeysUpdate:
                    print("Mediation Keys Update: \(message)")
                case .didcommPresentation:
                    print("Presentation: \(message)")
                case .didcommRequestPresentation:
                    print("Request Presentation: \(message)")
                case .didcommProposePresentation:
                    print("Propose Presentation: \(message)")
                case .didcommCredentialPreview:
                    print("Credential Preview: \(message)")
                case .didcommCredentialPreview3_0:
                    print("Credential Preview 3.0: \(message)")
                case .didcommIssueCredential:
                    print("Issue Credential: \(message)")
                case .didcommIssueCredential3_0:
                    print("Issue Credential 3.0: \(message)")
                    
                    
//                    let issueCredential = try IssueCredential3_0(fromMessage: message)
//                    
//                    Task { @MainActor in
//                        do {
//                            print("-------------------------------")
//                            print("Attempting to process Credential")
//                            print("-------------------------------")
//                            let credential = try await self?.didCommAgent?.processIssuedCredentialMessage(message: issueCredential)
//                            print("-------------------------------")
//                            print("Processed Credential \(credential)")
//                            print("-------------------------------")
//                        } catch {
//                            print("PROCESSING CREDENTIAL FAILED")
//                        }
//                    }

                    
                    
                    
                case .didcommOfferCredential:
                    print("Offer Credential: \(message)")
                case .didcommOfferCredential3_0:
                    print("Offer Credential 3.0: \(message)")
                    
//                    guard let newPrismDID = try await self?.didCommAgent?.createNewPrismDID() else {
//                        print("Did not create new did")
//                        return
//                    }
//                    guard let requestCredential = try await self?.didCommAgent?.prepareRequestCredentialWithIssuer(
//                        did: newPrismDID,
//                        offer: try OfferCredential3_0(fromMessage: message)
//                    ) else { throw UnknownError.somethingWentWrongError() }
//                    _ = try await self?.didCommAgent?.sendMessage(message: try requestCredential.makeMessage())
//                    
                case .didcommProposeCredential:
                    print("Propose Credential: \(message)")
                case .didcommProposeCredential3_0:
                    print("Propose Credential 3.0: \(message)")
                case .didcommRequestCredential:
                    print("Request Credential: \(message)")
                case .didcommRequestCredential3_0:
                    print("Request Credential 3.0: \(message)")
                case .didcommconnectionRequest:
                    print("Connection Request: \(message)")
                case .didcommconnectionResponse:
                    print("Connection Response: \(message)")
                    
                    if let connectionAccept = try? ConnectionAccept(fromMessage: message) {
                        print("ConnectionAccept: \(connectionAccept)")
                        // Store connectionId
//                                            if let thid = connectionAccept.thid {
//                                                if !self.storeConnectionIdInKeychain(connectionId: thid) {
//                                                    print("Connection ID was not saved, and this should be a proper error, not a print statement")
//                                                }
//                                            }
                    }
                    
                case .didcommRevocationNotification:
                    print("Revocation Notification: \(message)")
                case .didcomminvitation:
                    print("DIDComm Invitation: \(message)")
                case .didcommReportProblem:
                    print("Report Problem: \(message)")
                case .prismOnboarding:
                    print("PRISM Onboarding: \(message)")
                case .pickupRequest:
                    print("Pickup Request: \(message)")
                case .pickupDelivery:
                    print("Pickup Delivery: \(message)")
                case .pickupStatus:
                    print("Pickup Status: \(message)")
                case .pickupReceived:
                    print("Pickup Received: \(message)")
                    //            default:
                    //                print("Unknown Message is: \(message)")
                }
            }
            print("\n-------------------------\n")
            
            
            
            
            
//            do {
//                if let issued = try? IssueCredential(fromMessage: message) {
//                    
//                    print("Issued: \(issued)")
//                    
//                    _ = try issued.attachments.compactMap {
//                        switch $0.data {
//                        case let data as AttachmentBase64:
//                            // is this where we call processCredential(data)?
//                            break
//                        default:
//                            return
//                        }
//                    }
//                }
//            } catch {
//                print(error)
//            }
        }
        .store(in: &cancellables)
    }
    
    private func connectionExists(connectionId: String, label: String?) async throws -> Bool {
        let networkActor = APIClient(configuration: FlightTixURLSession(mode: .development, config: urlSessionConfig as! FlightTixSessionConfigStruct))
        do {
            guard let connections = try await networkActor.cloudAgent.getConnections() else {
                return false
            }
            return connections.contents.contains(where: { $0.connectionId == connectionId && $0.label == label })
        } catch {
            throw error
        }
    }
}


extension Encodable {
    var prettyPrintedJSONString: String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let data = try? encoder.encode(self) else { return nil }
        return String(data: data, encoding: .utf8) ?? nil
    }
}
