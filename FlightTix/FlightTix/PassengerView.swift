//
//  PassengerView.swift
//  FlightTix
//
//  Created by Jon Bauer on 11/9/24.
//

import SwiftUI

enum Flights: String, CaseIterable, Identifiable {
    case atl2scl = "ATL -> SCL 20:00 Mar 23, 2025",
         ams2vie = "AMS -> VIE 09:30 May 29, 2025",
         sfo2hnd = "SFO -> HND 11:00 Oct 25, 2025"
    var id: Self { self }
}

struct PassengerView: View {
    
    @State private var presentingProfile = false
    
    @State private var selectedFlight: Flights = .atl2scl
    
    private func showProfile() {
        presentingProfile = true
    }
    
    private func didDismiss() {}
    
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
                    }
                    .padding(.trailing, 24)
                    .fullScreenCover(isPresented: $presentingProfile, onDismiss: didDismiss, content: {
                        Profile()
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
