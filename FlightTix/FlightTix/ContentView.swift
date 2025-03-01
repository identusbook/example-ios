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
    
    @State private var identus: Identus?
    @State private var auth: Auth?
    
    @State var showRegisterScreen: Bool = false
    @State private var selectedTab: NavigationItem = .purchase
    @State private var viewState: ViewState = .loading
    
    private func reloadModels() { print("reloading models...") }
    
    var body: some View {
        
        switch viewState {
        case .loading:
            LoadingScreen()
                .onAppear() {
                    
                    // Initialize Identus, if we fail to initialize, throw error
                    Task {
                        do {
                            Identus.setup(IdentusConfig()) // must call Identus.setup(IdentusConfig()) before first use
//                            try await Identus.shared.tearDown()
//                            return

                                try await Identus.shared.startUpAndConnect()
                                print(Identus.shared.status)
                                
                                if Identus.shared.status == "running" {
                                    print("we should transition from LoadingScreen to Content")
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        viewState = .tabs
                                    }
                                }
                            
                        } catch {
                            throw error
                        }
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
    private func showRegisterScreenIfNoLoginVC() async {
        if await !Auth.shared.isLoggedIn() {
            showRegisterScreen = true
        }
    }
}

#Preview {
    ContentView()
}
