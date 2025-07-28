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
        ZStack {
            VStack {
                Text("Choose Flight:")
                Picker("Flights", selection: $selectedFlight) {
                    ForEach(model.availableFlights, id: \.self) { flight in
                        Text("\(flight.departure) → \(flight.arrival) – \(flight.price, format: .currency(code: "USD"))").tag(flight)
                    }
                }
                .pickerStyle(.menu)
                
                Button  {
                    Task {
                        try await model.purchaseTicket(for: Flight(departure: selectedFlight!.departure, arrival: selectedFlight!.arrival, price: selectedFlight!.price))
                    }
                } label: {
                    Text("Purchase Ticket")
                }
                .buttonStyle(.bordered)
            }
            
            VStack {
                HStack {
                    Spacer()
                    Button  {
                        modalManager.show(.profile)
                    } label: {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 44, height: 44)
                    }
                    .padding(.trailing, 24)
                }
                .padding(.top, 8)
                Spacer()
            }
            
        }
        .onAppear {
            // assign from the exact array coming out of your VM
            if selectedFlight == nil {
                selectedFlight = model.availableFlights.first
            }
        }
    }
}

//#Preview {
//    PurchaseView()
//}
