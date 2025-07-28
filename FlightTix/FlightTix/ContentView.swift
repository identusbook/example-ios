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
    case devTools
}

enum ViewState {
    case loading
    case login
    case tabs
}

enum ActiveModal: Identifiable {
    case profile
    case register

    var id: String {
        switch self {
        case .profile: return "profile"
        case .register: return "register"
        }
    }
}

struct ContentView: View {
    
    @State private var identus: Identus?
    @State private var auth: Auth?
    
    @State private var selectedTab: NavigationItem = .purchase
    @State private var viewState: ViewState = .loading
    
    private let identusStatus = IdentusStatus.shared
    
    private func reloadModels() { print("reloading models...") }
    
    @EnvironmentObject var modalManager: ModalManager
    
    var body: some View {
        
        switch viewState {
        case .loading:
            LoadingScreen()
                .onAppear() {
                    
                    // Initialize Identus, if we fail to initialize, throw error
                    Task {
                        do {
                            Identus.setup(IdentusConfig()) // must call Identus.setup(IdentusConfig()) before first use
//                             TODO: remember to wipe the Simulator to reset CoreDate because it only appends
                            try await Identus.shared.startUpAndConnect()
                            print(Identus.shared.status)
                            if identusStatus.status == .ready {
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
                PurchaseView()
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
                DevUtils()
                    .tabItem {
                        Label("Dev Utils", systemImage: "wrench.and.screwdriver")
                    }
                    .tag(NavigationItem.devTools)
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
            .fullScreenCover(item: $modalManager.activeModal) { modal in
                switch modal {
                case .profile:
                    ProfileScreen()
                case .register:
                    RegisterScreen()
                }
            }
            .edgesIgnoringSafeArea(.all)
        }
    }
    
    @MainActor
    private func showRegisterScreenIfNoLoginVC() async {
        if await !Auth.shared.isLoggedIn() {
            //showRegisterScreen = true
            modalManager.show(.register)
        }
    }
}

#Preview {
    ContentView()
}
