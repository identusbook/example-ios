//
//  SecurityView.swift
//  FlightTix
//
//  Created by Jon Bauer on 11/9/24.
//

import SwiftUI

struct SecurityView: View {

    @StateObject private var vm = SecurityViewModel()

    var body: some View {
        VStack(spacing: 16) {
            ScreenHeader(title: "Airport Security",
                         subtitle: "Request and verify a traveller's credentials.")
                .accessibilityIdentifier("security.header")

            Button {
                Task { await vm.requestProofOfTicketAndPassport() }
            } label: {
                Text("Request Proof of Ticket")
            }
            .buttonStyle(.primary)
            .disabled(vm.isBusy)
            .padding(.horizontal)
            .accessibilityIdentifier("security.requestProofButton")

            if vm.isBusy {
                HStack(spacing: 8) {
                    ProgressView()
                    Text(busyLabel).foregroundStyle(.secondary)
                }
            }

            if case let .error(message) = vm.requestState {
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .accessibilityIdentifier("security.errorMessage")
            }

            presentationsList
        }
        .padding(.top)
        .task { await vm.loadPresentations() }
        .sheet(item: $vm.proofUnderReview) { review in
            ProofReviewSheet(
                review: review,
                onAccept: { await vm.accept() },
                onDeny: { await vm.deny() }
            )
            .bottomSheetDetents()
        }
    }

    private var busyLabel: String {
        switch vm.requestState {
        case .requesting: return "Creating proof request…"
        case .awaiting:   return "Waiting for wallet to present proof…"
        default:          return ""
        }
    }

    @ViewBuilder
    private var presentationsList: some View {
        if vm.presentations.isEmpty {
            Spacer()
            Text("No presentations yet.\nRequest proof of a ticket to get started.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .accessibilityIdentifier("security.emptyState")
            Spacer()
        } else {
            List {
                Section("Previous Presentations") {
                    ForEach(vm.presentations) { row in
                        PresentationRowView(row: row)
                    }
                }
            }
            .accessibilityIdentifier("security.presentationsList")
        }
    }
}

private struct PresentationRowView: View {
    let row: PresentationRow

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(statusColor)
                .frame(width: 10, height: 10)
            VStack(alignment: .leading, spacing: 2) {
                Text(row.status)
                    .font(.subheadline).fontWeight(.medium)
                Text(row.presentationId)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            Spacer()
        }
        .padding(.vertical, 2)
    }

    private var statusColor: Color {
        switch row.status {
        case "PresentationVerified", "PresentationAccepted": return .green
        case "PresentationVerificationFailed", "PresentationRejected", "RequestRejected": return .red
        default: return .orange
        }
    }
}

private extension View {
    /// Presents as a bottom sheet with detents on iOS 16+, a standard sheet otherwise.
    @ViewBuilder
    func bottomSheetDetents() -> some View {
        if #available(iOS 16.0, *) {
            self.presentationDetents([.medium, .large])
        } else {
            self
        }
    }
}

#Preview {
    SecurityView()
}
