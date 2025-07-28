//
//  FlightTixApp.swift
//  FlightTix
//
//  Created by Jon Bauer on 11/9/24.
//

import SwiftUI

@main
struct FlightTixApp: App {
    
    @StateObject private var modalManager = ModalManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(modalManager)
        }
    }
}
