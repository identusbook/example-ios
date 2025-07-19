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

enum AppModal: Identifiable, Equatable {
    
    case none
    case profile

    var id: String {
        switch self {
        case .none: return "none"
        case .profile: return "profile"
        }
    }
}

struct ContentView: View {
    
    @State private var identus: Identus?
    @State private var auth: Auth?
    
    @State var showRegisterScreen: Bool = false
    @State private var selectedTab: NavigationItem = .purchase
    @State private var viewState: ViewState = .loading
    
    private let identusStatus = IdentusStatus.shared
    
    private func reloadModels() { print("reloading models...") }
    
    @State private var modal: AppModal?
    
    // Show a modal (replaces any currently showing one)
    private func showModal(_ newModal: AppModal) {
        if modal != newModal {
            modal = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                modal = newModal
            }
        }
    }
    
    // Dismiss the modal
    private func dismissModal() {
        modal = nil
    }
    
    // Return the appropriate modal view
    @ViewBuilder
    private func modalView(for modal: AppModal) -> some View {
        switch modal {
        case .none:
            EmptyView()
        case .profile:
            ProfileScreen(onClose: dismissModal)
        }
    }
    
    
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
            .fullScreenCover(isPresented: $showRegisterScreen,
                             onDismiss: reloadModels,
                             content: {
                RegisterScreen()
            })
            .animation(.interactiveSpring(response: 0.4, dampingFraction: 0.85, blendDuration: 0.25), value: modal)
            .edgesIgnoringSafeArea(.all)
        }
        
        
        // Modal overlay
        if let modal = modal {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { dismissModal() }

            modalView(for: modal)
                .transition(.asymmetric(
                    insertion: .move(edge: .bottom).combined(with: .opacity),
                    removal: .move(edge: .bottom).combined(with: .opacity)
                ))
                .zIndex(1)
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
