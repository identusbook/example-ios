//
//  Profile.swift
//  FlightTix
//
//  Created by Jon Bauer on 11/9/24.
//

import SwiftUI

struct Profile: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var profileLoaded: Bool = false
    
    var traveller: Traveller?
    
    private func logout() {
        dismiss()
    }
    
    var body: some View {
        ZStack {
            if !profileLoaded {
                Text("Loading Profile...")
            } else {
                VStack {
                    Text("Profile")
                    
                    Form {
                        Text("Name: \(String(describing: traveller?.name))")
                        Text("DID: \(String(describing: traveller?.did))")
                        Text("Passport Number: \(String(describing: traveller?.passportNumber))")
                        Text("Birthdate: \(String(describing: traveller?.dob))")
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                profileLoaded = true
            }
        }
    }
}

#Preview {
    Profile()
}
