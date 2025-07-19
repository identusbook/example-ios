//
//  ProfileScreen.swift
//  FlightTix
//
//  Created by Jon Bauer on 11/9/24.
//

import SwiftUI

struct ProfileScreen: View {
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var model: ProfileViewModel = ProfileViewModel()
    
    @State private var profileLoaded: Bool = false
    
    private func logout() {
        dismiss()
    }
    
    var onClose: () -> Void
    var body: some View {
        ZStack {
            if !profileLoaded {
                Text("Loading Profile...")
            } else {
                VStack {
                    Text("Profile")
                    
                    if let traveller = model.traveller {
                        Form {
                            Text("Name: \(String(describing: traveller.passport.name))")
                            Text("DID: \(String(describing: traveller.passport.did))")
                            Text("Passport Number: \(String(describing: traveller.passport.passportNumber))")
                            Text("Birthdate: \(String(describing: traveller.passport.dob))")
                        }
                    } else {
                        Form {
                            Text("Name:")
                            Text("DID:")
                            Text("Passport Number:")
                            Text("Birthdate:")
                        }
                    }
                    
                    
                    
                    Button  {
                        logout()
                    } label: {
                        Text("Close")
                    }
                    
                    Spacer()
                }
            }
        }
        .onAppear() {
            // Check for Passport VC
            // Load data from Passport VC
            Task {
                try await model.getTraveller()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    profileLoaded = true
                }
            }
            
        }
    }
}

//#Preview {
//    ProfileScreen(traveller: nil, onClose: {})
//}
