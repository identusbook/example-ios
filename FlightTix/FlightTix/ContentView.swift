//
//  ContentView.swift
//  FlightTix
//
//  Created by Jon Bauer on 11/9/24.
//

import SwiftUI
import EdgeAgentSDK

enum Flights: String, CaseIterable, Identifiable {
    case atl2scl = "ATL -> SCL 20:00 Mar 23, 2025",
         ams2vie = "AMS -> VIE 09:30 May 29, 2025",
         sfo2hnd = "SFO -> HND 11:00 Oct 25, 2025"
    var id: Self { self }
}

enum NavigationItem {
    case purchase
    case ticket
    case security
}

enum ViewState {
    case loading
    case login
    case tabs
}

struct ContentView: View {
    
    @State var showRegisterScreen: Bool = false
    @State private var selectedTab: NavigationItem = .purchase
    @State private var viewState: ViewState = .loading
    
    private func reloadModels() { print("reloading models...") }
    
    var body: some View {
        
        switch viewState {
        case .loading:
            LoadingScreen()
                .onAppear() {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        viewState = .tabs
                    }
                }
        case .login:
            RegisterScreen()
        case .tabs:
            TabView(selection: $selectedTab) {
                PassengerView()
                    .tabItem {
                        Label("Purchase", systemImage: "airplane")
                    }
                    .tag(NavigationItem.purchase)
                
                TicketTab()
                    .tabItem {
                        Label("Ticket", systemImage: "ticket")
                    }
                    .tag(NavigationItem.ticket)
                
                SecurityView()
                    .tabItem {
                        Label("Airport Security", systemImage: "hand.raised.circle")
                    }
                    .tag(NavigationItem.security)
            }
            .onAppear() {
                Task {
                    _ = await showRegisterScreenIfNoLoginVC()
                }
            }
            .onChange(of: selectedTab) { newState in
                Task {
                    _ = await showRegisterScreenIfNoLoginVC()
                }
            }
            .fullScreenCover(isPresented: $showRegisterScreen,
                             onDismiss: reloadModels,
                             content: {
                RegisterScreen()
            })
        }
    }
    
    @MainActor
    private func showRegisterScreenIfNoLoginVC() async -> Bool {
        
        // Check for existince of Login VC
        
        // If no Login VC, show Register Screen
        showRegisterScreen = true
        return true
    }
}

#Preview {
    ContentView()
}
