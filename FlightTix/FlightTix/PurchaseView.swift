//
//  PurchaseView.swift
//  FlightTix
//
//  Created by Jon Bauer on 11/9/24.
//

import SwiftUI

struct PurchaseView: View {
    @EnvironmentObject var modalManager: ModalManager
    @StateObject private var model: PurchaseViewModel = PurchaseViewModel()
    @State private var presentingProfile = false
    @State private var selectedFlight: Flight? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Title row with the profile shortcut inline so nothing overlaps.
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Purchase").font(.largeTitle.weight(.bold))
                    Text("Buy a flight to receive a ticket credential.")
                        .font(.subheadline).foregroundColor(.secondary)
                }
                Spacer()
                Button {
                    modalManager.show(.profile)
                } label: {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 36, height: 36)
                        .foregroundColor(.accentColor)
                }
            }
            .padding(.horizontal)

            VStack(alignment: .leading, spacing: 8) {
                Text("Choose Flight").font(.headline)
                Picker("Flights", selection: $selectedFlight) {
                    ForEach(model.availableFlights, id: \.self) { flight in
                        Text("\(flight.departure) → \(flight.arrival) – \(flight.price, format: .currency(code: "USD"))").tag(flight)
                    }
                }
                .pickerStyle(.menu)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.secondarySystemBackground),
                            in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .padding(.horizontal)

            AsyncButton("Purchase Ticket") {
                guard let selectedFlight else { return }
                do {
                    try await model.purchaseTicket(for: Flight(departure: selectedFlight.departure, arrival: selectedFlight.arrival, price: selectedFlight.price))
                } catch {
                    print("Purchase failed: \(error)")
                }
            }
            .buttonStyle(.primary)
            .disabled(selectedFlight == nil)
            .padding(.horizontal)

            Spacer()
        }
        .padding(.top)
        .onAppear {
            // assign from the exact array coming out of your VM
            if selectedFlight == nil {
                selectedFlight = model.availableFlights.first
            }
        }
        .alert("Ticket Issued ✈️", isPresented: $model.purchaseComplete) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your ticket credential has been issued to your wallet. You can view it on the Ticket tab.")
        }
    }
}

//#Preview {
//    PurchaseView()
//}
