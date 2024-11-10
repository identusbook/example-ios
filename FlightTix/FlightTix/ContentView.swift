//
//  ContentView.swift
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

struct ContentView: View {
    var body: some View {
        TabView {
            PassengerView()
                .tabItem {
                    Label("Purchase", systemImage: "airplane")
                }
            
            TicketView()
                .tabItem {
                    Label("Ticket", systemImage: "ticket")
            }
            
            SecurityView()
                .tabItem {
                    Label("Airport Security", systemImage: "hand.raised.circle")
                }
        }
    }
}

#Preview {
    ContentView()
}
