//
//  SecurityViewModel.swift
//  FlightTix
//
//  Drives the Airport Security verifier flow: request proof of a Ticket (and
//  Passport), wait for the wallet to present and the Cloud Agent to verify,
//  let the officer Accept/Deny (recorded via the Cloud Agent), and list the
//  verifier's previous presentations.
//

import Foundation

/// A verified proof awaiting the officer's Accept/Deny decision.
struct ProofReview: Identifiable {
    let id = UUID()
    let ticketPresentationId: String
    let passportPresentationId: String
    let ticketValid: Bool
    let passportValid: Bool
    let ticketStatus: String
    let passportStatus: String

    var presentationIds: [String] { [ticketPresentationId, passportPresentationId] }
    var allValid: Bool { ticketValid && passportValid }
}

/// One row in the "previous Presentations" list.
struct PresentationRow: Identifiable {
    var id: String { presentationId }
    let presentationId: String
    let status: String
}

@MainActor
final class SecurityViewModel: ObservableObject {

    enum RequestState: Equatable {
        case idle
        case requesting   // creating the proof requests
        case awaiting     // waiting for the wallet to present + agent to verify
        case error(String)
    }

    /// The status the Cloud Agent reports once a presentation is cryptographically valid.
    static let validStatus = "PresentationVerified"

    @Published var requestState: RequestState = .idle
    @Published var proofUnderReview: ProofReview?
    @Published var presentations: [PresentationRow] = []

    var isBusy: Bool {
        switch requestState {
        case .requesting, .awaiting: return true
        default: return false
        }
    }

    /// Request proof of Ticket and Passport. Because the EdgeAgent SDK presents a
    /// single credential per presentation, this fires two proof requests and waits
    /// for both to verify, then surfaces the combined result for review.
    func requestProofOfTicketAndPassport() async {
        requestState = .requesting

        guard let ticketSchemaId = Identus.shared.readTicketSchemaIdFromKeychain() else {
            requestState = .error("No ticket schema found yet. Issue a ticket first.")
            return
        }
        guard let passportSchemaId = Identus.shared.readPassportSchemaIdFromKeychain() else {
            requestState = .error("No passport schema found yet. Register first.")
            return
        }

        do {
            guard let ticketRequest = try await Identus.shared.createProofRequest(schemaId: ticketSchemaId),
                  let passportRequest = try await Identus.shared.createProofRequest(schemaId: passportSchemaId) else {
                requestState = .error("Could not create the proof requests.")
                return
            }

            requestState = .awaiting

            // Both presentations are answered by the on-device wallet over DIDComm;
            // poll the Cloud Agent records concurrently until each reaches a result.
            async let ticketOutcome = Identus.shared.awaitPresentationOutcome(presentationId: ticketRequest.presentationId)
            async let passportOutcome = Identus.shared.awaitPresentationOutcome(presentationId: passportRequest.presentationId)
            let ticketRecord = try await ticketOutcome
            let passportRecord = try await passportOutcome

            proofUnderReview = ProofReview(
                ticketPresentationId: ticketRequest.presentationId,
                passportPresentationId: passportRequest.presentationId,
                ticketValid: ticketRecord?.status == Self.validStatus,
                passportValid: passportRecord?.status == Self.validStatus,
                ticketStatus: ticketRecord?.status ?? "Unknown",
                passportStatus: passportRecord?.status ?? "Unknown"
            )
            requestState = .idle
            await loadPresentations()
        } catch {
            requestState = .error("Proof request failed: \(error)")
        }
    }

    func accept() async { await recordDecision(accept: true) }
    func deny() async { await recordDecision(accept: false) }

    private func recordDecision(accept: Bool) async {
        guard let review = proofUnderReview else { return }
        for id in review.presentationIds {
            do {
                if accept {
                    _ = try await Identus.shared.acceptPresentation(presentationId: id)
                } else {
                    _ = try await Identus.shared.denyPresentation(presentationId: id)
                }
            } catch {
                print("Recording \(accept ? "accept" : "deny") for \(id) failed: \(error)")
            }
        }
        proofUnderReview = nil          // closes the sheet
        await loadPresentations()
    }

    func loadPresentations() async {
        do {
            guard let response = try await Identus.shared.getPresentations() else {
                presentations = []
                return
            }
            presentations = response.contents
                .filter { $0.role == "Verifier" }
                .map { PresentationRow(presentationId: $0.presentationId, status: $0.status) }
        } catch {
            print("loadPresentations error: \(error)")
        }
    }
}
