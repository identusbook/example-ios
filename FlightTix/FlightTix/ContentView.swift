//
//  ContentView.swift
//  FlightTix
//
//  Created by Jon Bauer on 11/9/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            PassengerView()
                .tabItem {
                    Label("Purchase Ticket", systemImage: "airplane")
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
