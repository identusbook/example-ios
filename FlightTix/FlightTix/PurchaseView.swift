//
//  PurchaseView.swift
//  FlightTix
//
//  Created by Jon Bauer on 11/9/24.
//

import SwiftUI

struct PurchaseView: View {
    
    @StateObject private var model: PurchaseViewModel = PurchaseViewModel()
    
    @State private var presentingProfile = false
    
    @State private var selectedFlight: Flight? = nil
    
    
    private func showProfile() {
        presentingProfile = true
    }
    private func didDismiss() { presentingProfile = false; }
    
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
                        showProfile()
                    } label: {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 44, height: 44)
                    }
                    .padding(.trailing, 24)
                    .fullScreenCover(isPresented: $presentingProfile, onDismiss: didDismiss, content: {
                        ProfileScreen(onClose: { presentingProfile = false; })
                    })
                    
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
