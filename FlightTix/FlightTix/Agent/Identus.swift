//
//  Identus.swift
//  FlightTix
//
//  Created by Jon Bauer on 12/15/24.
//

import Combine
import Foundation
import EdgeAgentSDK

class Identus: ObservableObject {
    
    @Published var agentRunning = false
    
    private var agent: EdgeAgent?
    private var cancellables = Set<AnyCancellable>()
    
    
    public func start(did: DID) async throws {
        guard let didString = UserDefaults.standard.string(forKey: "mediatorDID"),
              let did = try? DID(string: didString)
        else { return }
        
        //startAgentWithMediatorDID(did: did)
    }
    
    public func stop() async throws {
        // TODO: is there something better than to nil this out?
        // Do we need to shut it down properly?
        agent = nil
//        do {
//            try await agent?.stop()
//        } catch {
//            print("MEDIATOR COULD NOT STOP AGENT")
//        }
    }
    
    // Private Agent
//    private func startWaitingForConnections() {
//        agent?.handleReceivedMessagesEvents()
//            .drop {
//                (try? ConnectionRequest(fromMessage: $0)) == nil
//            }
//            .flatMap { message in
//                Future { [weak self] in
//                    guard let req = try? ConnectionRequest(fromMessage: message) else { return message }
//                    _ = try? await self?.agent?.sendMessage(message: ConnectionAccept(fromRequest: req).makeMessage())
//                    return message
//                }
//                .flatMap {
//                    self.createDIDPairOnConnection(message: $0)
//                }
//            }
//            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
//            .store(in: &cancellables)
//
//        agent?.handleReceivedMessagesEvents()
//            .drop {
//                (try? ConnectionAccept(fromMessage: $0)) == nil
//            }
//            .flatMap { message in
//                self.createDIDPairOnConnection(message: message)
//            }
//            .sink(receiveCompletion: { _ in
//                
//            }, receiveValue: {
//                
//            })
//            .store(in: &cancellables)
//    }

       
    
//    private func startAgentWithMediatorDID(did: DID) {
//        Task { [weak self] in
//            do {
//                let agent = PrismAgent(mediatorDID: did)
//                try await agent.start()
//                agent.startFetchingMessages()
//                self?.agent = agent
//                
//                startWaitingForConnections()
//                UserDefaults.standard.set(did.string, forKey: "mediatorDID")
//                await MainActor.run { [weak self] in
//                    self?.agentRunning = true
//                }
//            } catch {}
//        }
//    }
//
//    private func createDIDPairOnConnection(message: Message) -> Future<(), Error> {
//        Future { [weak self] in
//            guard
//                let from = message.from,
//                let to = message.to
//            else { return }
//            guard
//                let (did, alias) = try await self?.agent?.getDIDInfo(did: to)
//            else { return }
//            try await self?.agent?.registerDIDPair(
//                pair: DIDPair(
//                    holder: did,
//                    other: from,
//                    name: alias
//                ))
//            return
//        }
//    }
}
