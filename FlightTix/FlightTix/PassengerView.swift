//
//  PassengerView.swift
//  FlightTix
//
//  Created by Jon Bauer on 11/9/24.
//

import SwiftUI

struct PassengerView: View {
    
    @State private var presentingProfile = false
    
    @State private var selectedFlight: Flights = .atl2scl
    
    private func showProfile() {
        presentingProfile = true
    }
    
    private func didDismiss() { presentingProfile = false; }
    
    var body: some View {
        ZStack {
            VStack {
                Text("Choose Flight:")
                
                Picker("Flights", selection: $selectedFlight) {
                    ForEach(Flights.allCases) { flight in
                        Text(flight.rawValue)
                    }
                }
                
                Button  {
                    showProfile()
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
    }
}

#Preview {
    PassengerView()
}
