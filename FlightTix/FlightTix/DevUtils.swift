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
        ZStack {
            VStack {
                Spacer()
                Button {
                    Task {
                        do {
                            try await model.tearDown()
                        } catch {
                            throw error
                        }
                    }
                } label: {
                    Text("Reset Wallet")
                }
                .buttonBorderShape(.roundedRectangle)
                .buttonStyle(.bordered)
                .padding(.bottom, 40)
                
                HStack {
                    Button {
                        Task {
                            do {
                                try await model.startUp()
                            } catch {
                                throw error
                            }
                        }
                    } label: {
                        Text("Start Up and Connect")
                    }
                    .buttonBorderShape(.roundedRectangle)
                    .buttonStyle(.bordered)
                    
                    
                    Button {
                        Task {
                            do {
                                try await model.stop()
                            } catch {
                                throw error
                            }
                        }
                    } label: {
                        Text("Stop")
                    }
                    .buttonBorderShape(.roundedRectangle)
                    .buttonStyle(.bordered)
                }
                .padding(.bottom, 40)
                
                Button {
                    Task {
                        do {
                            
                            let isoString = "1976-03-23T00:00:00Z"
                            let formatter = ISO8601DateFormatter()

                            guard let dob = formatter.date(from: isoString) else {
                                print("❌ Failed to parse date.")
                                return
                            }
                            
                            try await model.issuePassport(passport: Passport(name: "Jon Bauer",
                                                                             did: "did:example:123",
                                                                             passportNumber: "12345",
                                                                             dob: Date(),
                                                                             dateOfIssuance: nil))
                            // Wait 30 seconds for for Credential dance before trying to verify
                            try await Task.sleep(nanoseconds: 30_000_000_000)
                            
                            // Verify: Request Proof of valid Passport VC
                            _ = try await model.requestProofOfPassport()
                            
                        } catch {
                            throw error
                        }
                    }
                } label: {
                    Text("Issue Passport")
                }
                .buttonBorderShape(.roundedRectangle)
                .buttonStyle(.bordered)
                .padding(.bottom, 40)
                
                Button {
                    Task {
                        do {
                            let flight = Flight(departure: "SFO", arrival: "TYO", price: 700.0)
                            
                            try await model.issueTicket(for: flight)
                            // Wait 30 seconds for for Credential dance before trying to verify
                            try await Task.sleep(nanoseconds: 30_000_000_000)
                            
                            // Verify: Request Proof of valid Ticket VC
                            _ = try await model.requestProofOfTicket()
                            
                        } catch {
                            throw error
                        }
                    }
                } label: {
                    Text("Issue Ticket")
                }
                .buttonBorderShape(.roundedRectangle)
                .buttonStyle(.bordered)
                .padding(.bottom, 40)
                Spacer()
            }
            .padding(.bottom, 40)
            
            Spacer()
        }
    }
}

#Preview {
    DevUtils(model: DevUtilsModel())
}
