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
import Domain
import JSONWebKey
import JSONWebSignature
import Core

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
    final class ShortFormOfDIDFromLongFormDIDFailedError: Error {}
    final class CreateSchemaError: Error {}
    final class SchemaIdFailedToSaveToKeychainError: Error {}
    final class PassportSchemaIdFailedToDeleteFromKeychainError: Error {}
    final class RequestIssuerDIDToBePublishedError: Error {}
    final class IssuerDIDNotPublishedError: Error {}
    final class PassportVCThidFailedToReadFromKeychainError: Error {}
    final class PassportVCThidFailedToDeleteFromKeychainError: Error {}
    final class PassportFailedToReadFromKeychainError: Error {}
    final class CredentialNotFoundError: Error {}
    final class PrepareRequestCredentialWithIssuerError: Error {}
    final class HandlePresentationFailedError: Error {}
    final class CheckForIssuerDIDPublishedFailed: Error {}
    
    final class HandleIssuedCredentialError: Error {}
    final class HandleOfferedCredentialError: Error {}
    final class HandleOfferedCredentialMessageNilError: Error {}
    final class HandleOfferedCredentialMakeMessageError: Error {}
    final class HandleOfferedCredentialSendMessageError: Error {}
    final class HandleOfferedCredentialCreatePrismDIDError: Error {}
    
    final class IssuerDIDFailedToSaveToKeychainError: Error {}
    final class IssuerDIDKeychainKeyNotPresentError: Error {}
    final class IssuerDIDFailedToDeleteFromKeychainError: Error {}
    
    final class PollDIDPublicationStatusPublishedTimeoutError: Error {}
    
    final class ProofRequestNotCreatedError: Error {}
    
    // Config
    let mediatorOOBURL: URL
    let mediatorDID: DID
    let seedKeychainKey: String
    let cloudAgentConnectionIdKeychainKey: String
    let cloudAgentConnectionLabel: String
    let cloudAgentIssuerDIDKeychainKey: String
    let passportIssueVCThidKeychainKey: String
    let ticketIssueVCThidKeychainKey: String
    let passportSchemaId: String
    let ticketSchemaId: String
    let passportSchemaIdKeychainKey: String
    let ticketSchemaIdKeychainKey: String
    let urlSessionConfig: URLSessionConfig
    
    // DIDComm Agent
    private var didCommAgent: DIDCommAgent?
    
    // Observable Properties
    @Published var status: String = ""
    @Published var error: String?
    
    // Combine
    private var credentialCancellables = Set<AnyCancellable>()
    private var messageCancellables = Set<AnyCancellable>()
    
    private var uuid: UUID = UUID()
    
    // Singleton Configuration
    private static var config: IdentusConfig?
    class func setup(_ config: IdentusConfig){
        Identus.config = config
    }
    
    // Singleton Init with Configuration
    static var shared: Identus = Identus(config: IdentusConfig())
    private init(config: IdentusConfig) {
        print("Identus init called using uuid: \(uuid)")
        
        guard let config = Identus.config else { fatalError("Identus config not set. Must call Identus.setup(IdentusConfig()) before first use.") }
        
        mediatorOOBURL = URL(string: config.mediatorOOBString)!
        mediatorDID = try! DID(string: config.mediatorDidString)
        seedKeychainKey = config.seedKeychainKey
        cloudAgentConnectionIdKeychainKey = config.cloudAgentConnectionIdKeychainKey
        cloudAgentIssuerDIDKeychainKey = config.cloudAgentIssuerDIDKeychainKey
        passportIssueVCThidKeychainKey = config.passportIssueVCThidKeychainKey
        passportSchemaId = config.passportSchemaId
        passportSchemaIdKeychainKey = config.passportSchemaIdKeychainKey
        ticketSchemaIdKeychainKey = config.ticketSchemaIdKeychainKey
        ticketSchemaId = config.ticketSchemaId
        ticketIssueVCThidKeychainKey = config.ticketIssueVCThidKeychainKey
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
    
    public func acceptDIDCommInvite(invitationFromCloudAgent: OutOfBandInvitation) async throws -> OutOfBandInvitation? {
        
        do {
            print("Attempt to accept Cloud Agent Invitation")
            try await didCommAgent?.acceptDIDCommInvitation(invitation: invitationFromCloudAgent)
            print("we should have accepted the invitation")
            return invitationFromCloudAgent

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
    
    public func startUpAndConnect() async throws {
        do {
            // Start DIDCommAgent
            try await start()
            
            // Start receiving messages from Pluto
            await startMessageStream()
            
            // Create a Connection to Cloud-Agent if it does not already exist
            try await createConnectionToCloudAgentIfNotExists()
            
            // Create Issuer DID on Cloud-Agent if it does not already exist
            try await createIssuerDIDOnCloudAgentIfNotExists()
            
            // Publish Schemas and store SchemaIds for later reference
            try await createPassportSchemaIfNotExists()
            // TODO
            //try await createTicketSchemaIfNotExists()
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
            
            if readIssuerDIDFromKeychain() != nil {
                guard deleteIssuerDIDFromKeychain() else { throw IssuerDIDFailedToDeleteFromKeychainError() }
                print("Deleted IssuerDID from Keychain")
            }
            
            if readConnectionIdFromKeychain() != nil {
                guard deleteConnectionIdFromKeychain() else { throw ConnectionFailedToDeleteFromKeychainError() }
                print("Deleted ConnectionId from Keychain")
            }
            
            if readPassportVCThidFromKeychain() != nil {
                guard deletePassportVCThidFromKeychain() else { throw PassportVCThidFailedToDeleteFromKeychainError() }
                print("Deleted PassportVCThid from Keychain")
            }
            
            if readPassportSchemaIdFromKeychain() != nil {
                guard deletePassportSchemaIdFromKeychain() else { throw PassportSchemaIdFailedToDeleteFromKeychainError() }
                print("Deleted PassportSchemaId from Keychain")
            }
            
            print("Identus has been torn down")
        } catch {
            throw error
        }
    }
    
    public func stop() async throws {
        try await didCommAgent?.stop()
        print("DidcommAgent stopped")
    }
    
    /// MARK - CONNECTIONS
    
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
            guard let invitationFromCloudAgent else {
                return
            }
            // Here we have a invitationId which is the same as the connectionId, can we rely on that being the same?
            let invitationIdToBeAccepted = invitationFromCloudAgent.id
            let acceptedInvitation = try await Identus.shared.acceptDIDCommInvite(invitationFromCloudAgent: invitationFromCloudAgent)
            
            guard let acceptedInvitationIdToBeStored = acceptedInvitation?.id else {
                return
            }
            
            if invitationIdToBeAccepted == acceptedInvitationIdToBeStored {
                // Store as connectionId
                if !self.storeConnectionIdInKeychain(connectionId: invitationIdToBeAccepted) {
                    print("Connection ID was not saved, and this should be a proper error, not a print statement")
                }
            }
            
        } catch {
            print(error)
        }
    }
    
    
    /// MARK - DIDs
    
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
    
    public func storeIssuerDIDInKeychain(shortFormDID: String) -> Bool {
        let keychain = KeychainSwift()
        let encodedDID = shortFormDID.encodeBase64()
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
            // TODO: Maybe we should make this more accurate, and look for a whitelist of known Issuer DIDs?
            let didsOnCloudAgent = try await Identus.shared.getDIDsOnCloudAgent()
            guard didsOnCloudAgent.contents.isEmpty else {
                // We already have an Issuer DID on Cloud Agent, do nothing
                // note that we will not have access to the long form since the Issuer is already published
                print("Cloud-Agent Issuer DID already exists.")

                let first = didsOnCloudAgent.contents.first!
                
                guard let shortFormDid = first?.did else {
                    print("Could not get ShortForm DID for Cloud-Agent Issuer DID")
                    return
                }

                //Use this Issuer DID
                guard storeIssuerDIDInKeychain(shortFormDID: shortFormDid) else {
                    print("Could not store Cloud-Agent Issuer DID in keychain")
                    throw IssuerDIDFailedToSaveToKeychainError()
                }
                
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
                
                do {
                    // Wait for Issuer DID to be published before moving on
                    // This takes a while but not much will work without this so worth the wait
                    // Only happens in a clean cold start
                    try await self.pollIssuerCheckDIDStatusPublished(shortOrLongFormDID: createDIDResponse.longFormDid)
                    
                } catch {
                    throw CheckForIssuerDIDPublishedFailed()
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
        throw IssuerDIDNotPublishedError()
    }
    
    func pollIssuerCheckDIDStatusPublished(shortOrLongFormDID: String) async throws {
        
        var checkIssuerStatusTask: Task<Void, Error>? = nil
        
        func pollIssuerDIDPublicationStatusPublished(shortOrLongFormDID: String) async throws {
            let interval = 1.0
            while true {
                try Task.checkCancellation()
                
                let isPublished = try await self.verifyIssuerDIDIsPublished(shortOrLongFormDID: shortOrLongFormDID)
                print("Is Issuer DID Published yet?: \(isPublished ? "Yes" : "No")")
                if isPublished {
                    print("Issuer DID is published, stopping polling.")
                    stopCheckingStatus()
                    return
                }
                try await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
            }
        }
        
        func startCheckingForStatus(shortOrLongFormDID: String) {
            checkIssuerStatusTask = Task.detached {
                try await pollIssuerDIDPublicationStatusPublished(shortOrLongFormDID: shortOrLongFormDID)
            }
        }
        
        func stopCheckingStatus() {
            checkIssuerStatusTask?.cancel()
            checkIssuerStatusTask = nil
        }
        
        // Start Polling for Issuer Status
        startCheckingForStatus(shortOrLongFormDID: shortOrLongFormDID)
    }
    
    public func didShortForm(from longFormDID: String) async throws -> DID? {
        let networkActor = APIClient(configuration: FlightTixURLSession(mode: .development, config: urlSessionConfig as! FlightTixSessionConfigStruct))
        do {
            if let did = try await networkActor.cloudAgent.didStatus(shortOrLongFormDID: longFormDID) {
                return try DID(string: did.did)
            }
        } catch {
            throw error
        }
        throw ShortFormOfDIDFromLongFormDIDFailedError()
    }
    
    /// MARK - CREDENTIALS
    
    /// MARK - PASSPORT CREDENTIALS
    public func createPassportCredentialOffer(request: CreateCredentialOfferRequest) async throws -> CreateCredentialOfferResponse {
        let networkActor = APIClient(configuration: FlightTixURLSession(mode: .development, config: urlSessionConfig as! FlightTixSessionConfigStruct))
        do {
            if let offer = try await networkActor.cloudAgent.createPassportCredentialOffer(request: request) {
                print("We created a credential offer!")
                return offer
            }
        } catch {
            throw error
        }
        throw CredentialOfferRequestFailedError()
    }
    /// MARK - TICKET CREDENTIALS
    public func createTicketCredentialOffer(request: CreateTicketCredentialOfferRequest) async throws -> CreateTicketCredentialOfferResponse {
        let networkActor = APIClient(configuration: FlightTixURLSession(mode: .development, config: urlSessionConfig as! FlightTixSessionConfigStruct))
        do {
            if let offer = try await networkActor.cloudAgent.createTicketCredentialOffer(request: request) {
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
        .store(in: &credentialCancellables)
        
        //return credentials ?? []
    }
    
    func loadVerifiableCredentials() async throws -> [Credential] {
        try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?

            cancellable = self.didCommAgent?.edgeAgent.verifiableCredentials()
                .replaceEmpty(with: []) // emits an empty array if no value
                .first()
                .sink(
                    receiveCompletion: { completion in
                        defer { cancellable?.cancel() }
                        if case .failure(let error) = completion {
                            continuation.resume(throwing: error)
                        }
                        // Cancel the subscription on completion
                        cancellable?.cancel()
                        cancellable = nil
                    },
                    receiveValue: { credentials in
                        defer { cancellable?.cancel() }
                        continuation.resume(returning: credentials)
                        // Cancel after value is received to prevent leaks
                        cancellable?.cancel()
                        cancellable = nil
                    }
                )
        }
    }
    
    private var credentialListCancellables = Set<AnyCancellable>()
    func fetchCredentials() async throws -> [Credential] {
        guard let sdkFunctionPublisher = didCommAgent?.edgeAgent.verifiableCredentials() else { return [] }
        return try await fetchCredentials(using: sdkFunctionPublisher)
    }
    
    func fetchCredentials(using publisher: AnyPublisher<[Credential], Error>) async throws -> [Credential] {
        return try await withCheckedThrowingContinuation { continuation in
            var isContinuationResumed = false
            
            publisher
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("finished fetching credentials")
                        break
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }, receiveValue: { credentials in
                    guard !isContinuationResumed else { return }
                    isContinuationResumed = true
                    continuation.resume(returning: credentials)
                })
                .store(in: &credentialListCancellables)
        }
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
    
    public func storePassportVCThidInKeychain(thid: String) -> Bool {
        let keychain = KeychainSwift()
        return keychain.set(thid, forKey: passportIssueVCThidKeychainKey)
    }
    
    public func readPassportVCThidFromKeychain() -> String? {
        let keychain = KeychainSwift()
        return keychain.get(passportIssueVCThidKeychainKey)
    }
    
    private func deletePassportVCThidFromKeychain() -> Bool {
        let keychain = KeychainSwift()
        return keychain.delete(passportIssueVCThidKeychainKey) ? true : false
    }
    
    public func storeTicketVCThidInKeychain(thid: String) -> Bool {
        let keychain = KeychainSwift()
        return keychain.set(thid, forKey: passportIssueVCThidKeychainKey)
    }
    
    public func readTicketVCThidFromKeychain() -> String? {
        let keychain = KeychainSwift()
        return keychain.get(passportIssueVCThidKeychainKey)
    }
    
    private func deleteTicketVCThidFromKeychain() -> Bool {
        let keychain = KeychainSwift()
        return keychain.delete(passportIssueVCThidKeychainKey) ? true : false
    }
    
    @MainActor
    private func startMessageStream() {
        
        var messageIndex: Int = 0
        var lastProcessedMessageCreatedTime: Date?
        
        didCommAgent?.startFetchingMessages()
        didCommAgent?.handleReceivedMessagesEvents()
            .receive(on: DispatchQueue.main)
            .flatMap(maxPublishers: .max(1)) { message -> AnyPublisher<Message, Error> in
            
            Future<Message, Error> { promise in
                Task {
                    do {
                        guard message.direction == .received,
                              let msgType = ProtocolTypes(rawValue: message.piuri)
                        else {
                            promise(.success(message))
                            return
                        }
                        messageIndex = messageIndex + 1
                        
                        if let messageCreatedTime = lastProcessedMessageCreatedTime {
                            if messageCreatedTime >= message.createdTime {
                                promise(.success(message))
                                return
                            }
                        }
                        
                        print("Message CreatedTime: \(message.createdTime)")
                        
                        switch msgType {
                        case .didcommBasicMessage,
                                .didcommMediationRequest,
                                .didcommMediationGrant,
                                .didcommMediationDeny,
                                .didcommMediationKeysUpdate,
                                .didcommCredentialPreview,
                                .didcommCredentialPreview3_0,
                                .didcommIssueCredential,
                                .didcommProposeCredential,
                                .didcommProposeCredential3_0,
                                .didcommRequestCredential,
                                .didcommRequestCredential3_0,
                                .didcommconnectionRequest,
                                .didcommRevocationNotification,
                                .didcomminvitation,
                                .didcommReportProblem,
                                .prismOnboarding,
                                .didcommOfferCredential,
                                .pickupStatus,
                                .pickupDelivery,
                                .pickupReceived,
                                .pickupRequest,
                                .didcommProposePresentation,
                                .didcommPresentation:
                            print("Unhandled Message Type: \(message) \n")
                        case .didcommconnectionResponse:
                            print("Connection Response Message Received \n")
                        case .didcommOfferCredential3_0:
                            // An offer for a Credential has been made
                            _ = try await self.handleOfferedCredential(message: message)
                            lastProcessedMessageCreatedTime = message.createdTime
                        case .didcommIssueCredential3_0:
                            // A Credential has been issued, process and save it to our wallet
                            _ = try await self.handleIssuedCredential(message: message)
                            lastProcessedMessageCreatedTime = message.createdTime
                        case .didcommRequestPresentation:
                            // A Verifier has created a Presentation Request
                            _ = try await self.handleRequestPresentation(message: message, ticketOnly: false)
                            lastProcessedMessageCreatedTime = message.createdTime
                        }
                        promise(.success(message))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
            .eraseToAnyPublisher()
        }
        .sink(
            receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("Finished processing all items.")
                case .failure(let error):
                    print("Error occurred: \(error)")
                }
            },
            receiveValue: { value in
            }
        )
        .store(in: &messageCancellables)
    }
    
    private func handleOfferedCredential(message: Message) async throws -> RequestCredential3_0? {
        print("Offer Credential Received")
        let offerCredential = try OfferCredential3_0(fromMessage: message)
        
        // Handle Passport Credential
        // Make sure this Message is referring to the Passport
        // TODO: How do we filter for different Message types like Passport vs Ticket?
        // Process Passport VC Credential
        guard let expectedThidForPassportVCIssuance = self.readPassportVCThidFromKeychain() else {
            throw PassportVCThidFailedToReadFromKeychainError()
        }
        guard offerCredential.thid == expectedThidForPassportVCIssuance else {
            return nil
        }
        
        // Create Subject DID
        guard let newPrismDID: DID = try await self.didCommAgent?.createNewPrismDID() else {
            throw HandleOfferedCredentialCreatePrismDIDError()
        }
        
        // Prepare RequestCredential with Subject DID
        guard let requestCredential = try await self.didCommAgent?.prepareRequestCredentialWithIssuer(
            did: newPrismDID,
            offer: offerCredential
        ) else {
            throw PrepareRequestCredentialWithIssuerError()
        }
        
        // Create Message from RequestCredential
        let messageToSend: Message?
        do {
            messageToSend = try requestCredential.makeMessage()
            
        } catch {
            throw HandleOfferedCredentialMakeMessageError()
        }
        guard messageToSend != nil, let madeMessage = messageToSend else {
            throw HandleOfferedCredentialMessageNilError()
        }
        
        Task { @MainActor in
            do {
                _ = try await self.didCommAgent?.sendMessage(message: madeMessage)
            } catch {
                throw HandleOfferedCredentialSendMessageError()
            }
        }
        
        return requestCredential
    }
    
    private func handleIssuedCredential(message: Message) async throws {
        print("Credential Issued")
        let issueCredential = try IssueCredential3_0(fromMessage: message)
        
        Task { @MainActor in
            do {
                return try await self.didCommAgent?.processIssuedCredentialMessage(message: issueCredential)
            } catch {
                throw HandleIssuedCredentialError()
            }
        }
    }
    
    private func handleRequestPresentation(message: Message, ticketOnly: Bool) async throws -> Presentation? {
        
        let credential: Credential?
        
        if ticketOnly {
            guard let keychainTicketSchemaId = readTicketSchemaIdFromKeychain() else {
                print("Could not Read TicketSchema ID from keychain")
                return nil
            }
            do {
                credential = try await self.fetchCredential(ofSchema: keychainTicketSchemaId)
            } catch {
                fatalError("Can not fetch credential")
            }
            
            
        } else {
            credential = try await self.didCommAgent?.edgeAgent.verifiableCredentials().map { $0.first }
                .first()
                .await()
        }
        
        guard let credential else {
            print("Credential Not Found!")
            throw CredentialNotFoundError()
        }
        
        guard let presentation = try await self.didCommAgent?.edgeAgent.createPresentationForRequestProof(
            request: try RequestPresentation(fromMessage: message),
            credential: credential) else {
            throw HandlePresentationFailedError()
        }
        let presentationMessage = try presentation.makeMessage()
        
        Task { @MainActor in
            do {
                _ = try await self.didCommAgent?.sendMessage(message: presentationMessage)
            } catch {
                throw HandlePresentationFailedError()
            }
        }
        return presentation
    }
    
    func fetchCredential(ofSchema schemaId: String) async throws -> Credential? {
        
        do {
            let rawCredentials: [Credential] = try await loadVerifiableCredentials()
            
            for cred in rawCredentials {
                
                let jws = try JWS(jwsString: cred.id)
                
                // decode jws payload
                let jsonData = jws.payload // this is already `Data` decoded from Base64URL
                var knownSchemaId: String?
                do {
                    let decoder = JSONDecoder()
                    let credential = try decoder.decode(VerifiableCredentialEnvelope.self, from: jsonData)
                    for schema in credential.vc.credentialSchema {
                        
                        if let guid = extractSchemaGUID(from: schema.id) {
                            //                                print("✅ Extracted GUID:", guid)
                            knownSchemaId = guid
                            break
                        } else {
                            print("❌ No match found")
                        }
                    }
                    
                    
                } catch {
                    // It's probably a Ticket then, let's do the same thing for that
                }
                
                do {
                    let decoder = JSONDecoder()
                    let credential = try decoder.decode(TicketVerifiableCredentialEnvelope.self, from: jsonData)
                    for schema in credential.vc.credentialSchema {
                        
                        if let guid = extractSchemaGUID(from: schema.id) {
                            knownSchemaId = guid
                            break
                        } else {
                            print("❌ No match found")
                        }
                    }
                    
                } catch {
                    print("❌ Ticket Decoding failed:", error)
                }
                
                if knownSchemaId == Identus.shared.readPassportSchemaIdFromKeychain() {
                    print("THIS MUST BE THE Passport SCHEMA")
                }
                if knownSchemaId == Identus.shared.readTicketSchemaIdFromKeychain() {
                    print("THIS MUST BE THE Ticket SCHEMA")
                    return cred
                }
            }
        } catch {
            throw error
        }
        return nil
    }

    
    func extractSchemaGUID(from url: String) -> String? {
        let pattern = #"schemas/([a-f0-9\-]+)/schema"#
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
            return nil
        }
        
        let range = NSRange(url.startIndex..<url.endIndex, in: url)
        
        if let match = regex.firstMatch(in: url, options: [], range: range),
           let guidRange = Range(match.range(at: 1), in: url) {
            return String(url[guidRange])
        }
        
        return nil
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
    
    /// MARK - SCHEMAS

    /// MARK - Passport Schema
    public func storePassportSchemaIdInKeychain(id: String) -> Bool {
        let keychain = KeychainSwift()
        return keychain.set(id, forKey: passportSchemaIdKeychainKey)
    }
    
    public func readPassportSchemaIdFromKeychain() -> String? {
        let keychain = KeychainSwift()
        guard let schemaId = keychain.get(passportSchemaIdKeychainKey) else { return nil }
        return schemaId
    }
    
    private func deletePassportSchemaIdFromKeychain() -> Bool {
        let keychain = KeychainSwift()
        return keychain.delete(passportSchemaIdKeychainKey) ? true : false
    }
    
    private func createPassportSchemaIfNotExists() async throws {
        
        //TODO: Check to see if Passport Schema already exists on Cloud Agent
        // Only if not, run this code
        guard let savedPassportSchemaGuid = readPassportSchemaIdFromKeychain() else {
            try await createPassportSchema()
            return
        }
        guard let schemaExists = try await getPassportSchemaByGuid(guid: savedPassportSchemaGuid) else {
            try await createPassportSchema()
            return
        }
    }
    
    private func createPassportSchema() async throws {
        //make sure we have published author did
        guard let issuerDID = readIssuerDIDFromKeychain() else {
            throw IssuerDIDKeychainKeyNotPresentError()
        }
        guard let shortFormIssuerDID = try await Identus.shared.didShortForm(from: issuerDID) else {
            return
        }
        // TODO: Check why this fails
//        guard try await Identus.shared.verifyIssuerDIDIsPublished(shortOrLongFormDID: shortFormIssuerDID.string) else {
//            return
//        }
        
        let passportSchema = PassportSchema(guid: nil,
                                           name: "passport",
                                           version: "1.0.0",
                                           description: "Passport Schema",
                                           type: "https://w3c-ccg.github.io/vc-json-schemas/schema/2.0/schema.json",
                                           author: shortFormIssuerDID.string,
                                           tags: ["passport", "schema"],
                                           schema: PassportSchemaData(id: passportSchemaId,
                                                          schema: "https://json-schema.org/draft/2020-12/schema",
                                                          description: "Passport",
                                                          type: "object",
                                                          properties: PassportProperties(
                                                            name: PropertyDetails(type: "string", format: nil),
                                                            dateOfIssuance: PropertyDetails(type: "string", format: "date-time"),
                                                            passportNumber: PropertyDetails(type: "string", format: nil),
                                                            dob: PropertyDetails(type: "string", format: "date-time")
                                                          ),
                                                          required: ["name", "dateOfIssuance", "passportNumber", "dob"],
                                                          additionalProperties: true))
        
        let networkActor = APIClient(configuration: FlightTixURLSession(mode: .development, config: urlSessionConfig as! FlightTixSessionConfigStruct))
        do {
            let createdSchema = try await networkActor.cloudAgent.createPassportSchema(schema: passportSchema)
            if let schemaId = createdSchema?.guid {
                print("Passport Schema Created with ID: \(String(describing: schemaId))")
                guard storePassportSchemaIdInKeychain(id: schemaId) else {
                    throw SchemaIdFailedToSaveToKeychainError() }
            }
            
        } catch {
            throw CreateSchemaError()
        }
    }
    
    /// MARK - Ticket Schema
    public func storeTicketSchemaIdInKeychain(id: String) -> Bool {
        let keychain = KeychainSwift()
        return keychain.set(id, forKey: ticketSchemaIdKeychainKey)
    }
    
    public func readTicketSchemaIdFromKeychain() -> String? {
        let keychain = KeychainSwift()
        guard let schemaId = keychain.get(ticketSchemaIdKeychainKey) else { return nil }
        return schemaId
    }
    
    private func deleteTicketSchemaIdFromKeychain() -> Bool {
        let keychain = KeychainSwift()
        return keychain.delete(ticketSchemaIdKeychainKey) ? true : false
    }
    
    private func createTicketSchemaIfNotExists() async throws {
        
        //TODO: Check to see if Ticket Schema already exists on Cloud Agent
        // Only if not, run this code
        guard let savedTicketSchemaGuid = readTicketSchemaIdFromKeychain() else {
            try await createTicketSchema()
            return
        }
        guard let schemaExists = try await getTicketSchemaByGuid(guid: savedTicketSchemaGuid) else {
            try await createTicketSchema()
            return
        }
    }
    
    private func createTicketSchema() async throws {
        //make sure we have published author did
        guard let issuerDID = readIssuerDIDFromKeychain() else {
            throw IssuerDIDKeychainKeyNotPresentError()
        }
        guard let shortFormIssuerDID = try await Identus.shared.didShortForm(from: issuerDID) else {
            return
        }
        //        guard try await Identus.shared.verifyIssuerDIDIsPublished(shortOrLongFormDID: shortFormIssuerDID.string) else {
        //            return
        //        }
        
        let ticketSchema = TicketSchema(guid: nil,
                                           name: "ticket",
                                           version: "1.0.0",
                                           description: "Ticket Schema",
                                           type: "https://w3c-ccg.github.io/vc-json-schemas/schema/2.0/schema.json",
                                           author: shortFormIssuerDID.string,
                                           tags: ["ticket", "schema"],
                                        schema: TicketSchemaData(id: ticketSchemaId,
                                                          schema: "https://json-schema.org/draft/2020-12/schema",
                                                          description: "Ticket",
                                                          type: "object",
                                                          properties: TicketProperties(
                                                            name: PropertyDetails(type: "string", format: nil),
                                                            dateOfIssuance: PropertyDetails(type: "string", format: "date-time"),
                                                            flight: PropertyDetails(type: "string", format: nil)
                                                          ),
                                                          required: ["name", "dateOfIssuance", "dob"],
                                                          additionalProperties: true))
        
        let networkActor = APIClient(configuration: FlightTixURLSession(mode: .development, config: urlSessionConfig as! FlightTixSessionConfigStruct))
        do {
            let createdSchema = try await networkActor.cloudAgent.createTicketSchema(schema: ticketSchema)
            if let schemaId = createdSchema?.guid {
                print("Ticket Schema Created with ID: \(String(describing: schemaId))")
                guard storeTicketSchemaIdInKeychain(id: schemaId) else { throw SchemaIdFailedToSaveToKeychainError() }
            }
            
        } catch {
            throw error
        }
    }
    
    private func getPassportSchemaByGuid(guid: String) async throws -> PassportSchema? {
        
        let networkActor = APIClient(configuration: FlightTixURLSession(mode: .development, config: urlSessionConfig as! FlightTixSessionConfigStruct))
        do {
            guard let existingSchema = try await networkActor.cloudAgent.getPassportSchemaByGuid(guid: guid) else { return nil }
            return existingSchema
        } catch {
            throw error
        }
    }
    
    private func getTicketSchemaByGuid(guid: String) async throws -> TicketSchema? {
        
        let networkActor = APIClient(configuration: FlightTixURLSession(mode: .development, config: urlSessionConfig as! FlightTixSessionConfigStruct))
        do {
            guard let existingSchema = try await networkActor.cloudAgent.getTicketSchemaByGuid(guid: guid) else { return nil }
        } catch {
            throw error
        }
        return nil
    }
    
    /// Present Proof
    
    public func getPresentations() async throws -> PresentationsResponse? {
        let networkActor = APIClient(configuration: FlightTixURLSession(mode: .development, config: urlSessionConfig as! FlightTixSessionConfigStruct))
       // do {
//            guard let presentations = try await networkActor.cloudAgent.getPresentations() else {
//                return nil
//            }
            
            let presentations = try await networkActor.cloudAgent.getPresentations()
        //{
            print(presentations)
                
            return presentations
//            } else {
//                print("Get Presentations failed to return expected type")
//            }
            //return nil
//        } catch {
//            throw error
//        }
    }
    
    public func getPresentation(presentationId: String) async throws -> PresentationResponseContent? {
        let networkActor = APIClient(configuration: FlightTixURLSession(mode: .development, config: urlSessionConfig as! FlightTixSessionConfigStruct))
        do {
            guard let presentation = try await networkActor.cloudAgent.getProofPresentationRecord(presentationId: presentationId) else { return nil }
            return presentation
        } catch {
            throw error
        }
    }
    
    public func createProofRequest(schemaId: String) async throws -> PresentationResponseContent? {
        let networkActor = APIClient(configuration: FlightTixURLSession(mode: .development, config: urlSessionConfig as! FlightTixSessionConfigStruct))
        
        guard let connectionId = readConnectionIdFromKeychain() else { return nil }

        let proofPresentationRequest = CreateProofPresentationRequest(
                                                                      //goalCode: "flighttix-proof-request",
                                                                      //goal: "Request proof of credential",
                                                                      connectionId: connectionId,
                                                                      options: CreateProofPresentationRequest.Options(challenge: String(describing: UUID()), domain: "identusbook.com"),
                                                                      proofs: [CreateProofPresentationRequest.ProofRequestAuxRequest(schemaId: "http://localhost:8085/schema-registry/schemas/\(schemaId)/schema", trustIssuers: ["some-issuer"])])
        
        do {
            let presentation = try await networkActor.cloudAgent.createProofPresentation(request: proofPresentationRequest)
            return presentation
        } catch {
            print("CREATE PROOF REQUEST ERROR: \(error)")
            throw ProofRequestNotCreatedError()
        }
    }
    
    
    /// Verifiable Credentials Verification
}


extension Encodable {
    var prettyPrintedJSONString: String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let data = try? encoder.encode(self) else { return nil }
        return String(data: data, encoding: .utf8) ?? nil
    }
}
