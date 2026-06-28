//
//  ProofReviewSheet.swift
//  FlightTix
//
//  Bottom sheet shown to Airport Security after a proof has been presented and
//  verified. Shows Ticket / Passport validity and lets the officer Accept or Deny.
//

import SwiftUI

struct ProofReviewSheet: View {
    let review: ProofReview
    let onAccept: () async -> Void
    let onDeny: () async -> Void

    var body: some View {
        VStack(spacing: 24) {
            Text("Proof of Ticket")
                .font(.title2).bold()
                .padding(.top, 24)

            VStack(spacing: 16) {
                validityRow(title: "Ticket", valid: review.ticketValid, status: review.ticketStatus)
                Divider()
                validityRow(title: "Passport", valid: review.passportValid, status: review.passportStatus)
            }
            .padding()
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)

            if !review.allValid {
                Text("One or more credentials could not be verified.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Spacer(minLength: 0)

            HStack(spacing: 16) {
                AsyncButton("Deny", spinnerTint: .red) {
                    await onDeny()
                }
                .buttonStyle(.secondaryAction(tint: .red))
                .accessibilityIdentifier("proofReview.denyButton")

                AsyncButton("Accept") {
                    await onAccept()
                }
                .buttonStyle(.primary)
                .disabled(!review.allValid)   // accept only a fully verified proof
                .accessibilityIdentifier("proofReview.acceptButton")
            }
            .padding()
        }
        .accessibilityIdentifier("proofReview.sheet")
    }

    @ViewBuilder
    private func validityRow(title: String, valid: Bool, status: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: valid ? "checkmark.seal.fill" : "xmark.seal.fill")
                .font(.title2)
                .foregroundStyle(valid ? .green : .red)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline)
                Text(valid ? "Valid" : "Invalid · \(status)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier("proofReview.\(title.lowercased())Status")
            }
            Spacer()
        }
    }
}
