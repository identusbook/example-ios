//
//  DevUtils.swift
//  FlightTix
//
//  Created by Jon Bauer on 7/13/25.
//
import SwiftUI

struct DevUtils: View {
    
    @Environment(\.dismiss) private var dismiss

    @StateObject var model: DevUtilsModel = .init()
    
    var body: some View {
        VStack(spacing: 16) {
            ScreenHeader(title: "Dev Utils",
                         subtitle: "Issue test credentials and manage the agent.")
                .padding(.top)

            ScrollView {
                VStack(spacing: 16) {
                    AsyncButton("Issue Passport") {
                        do {
                            try await model.issuePassport(passport: Passport(name: "Jon Bauer",
                                                                             did: "did:example:123",
                                                                             passportNumber: "12345",
                                                                             dob: Date(),
                                                                             dateOfIssuance: nil))
                            // Wait 30 seconds for the Credential dance before trying to verify
                            try await Task.sleep(nanoseconds: 30_000_000_000)

                            // Verify: Request Proof of valid Passport VC
                            _ = try await model.requestProofOfPassport()
                        } catch {
                            print("Issue Passport failed: \(error)")
                        }
                    }
                    .buttonStyle(.primary)
                    .accessibilityIdentifier("devutils.issuePassportButton")

                    AsyncButton("Issue Ticket") {
                        do {
                            let flight = Flight(departure: "SFO", arrival: "TYO", price: 700.0)
                            try await model.issueTicket(for: flight)
                            // Wait 30 seconds for the Credential dance before trying to verify
                            try await Task.sleep(nanoseconds: 30_000_000_000)
                            // Verify: Request Proof of valid Ticket VC
                            _ = try await model.requestProofOfTicket()
                        } catch {
                            print("Issue Ticket failed: \(error)")
                        }
                    }
                    .buttonStyle(.primary)
                    .accessibilityIdentifier("devutils.issueTicketButton")

                    Divider().padding(.vertical, 8)

                    HStack(spacing: 12) {
                        Button {
                            Task { do { try await model.startUp() } catch { throw error } }
                        } label: {
                            Text("Start Up")
                        }
                        .buttonStyle(.secondaryAction)

                        Button {
                            Task { do { try await model.stop() } catch { throw error } }
                        } label: {
                            Text("Stop")
                        }
                        .buttonStyle(.secondaryAction)
                    }

                    Button {
                        Task { do { try await model.tearDown() } catch { throw error } }
                    } label: {
                        Text("Reset Wallet")
                    }
                    .buttonStyle(.secondaryAction(tint: .red))
                }
                .padding()
            }
        }
    }
}

#Preview {
    DevUtils(model: DevUtilsModel())
}
