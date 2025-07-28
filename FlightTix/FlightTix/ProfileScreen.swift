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
    
    var body: some View {
        ZStack {
            if !profileLoaded {
                Text("Loading Passport Details...")
            } else {
                VStack {
                    Text("Passport Details")
                    
                    if let traveller = model.traveller {
                        Form {
                            Text("Name: \(traveller.passport.name)")
                            Text("Passport Number: \(traveller.passport.passportNumber)")
                            Text("Birthdate: \(DateStuff.displayISODateAsString(traveller.passport.dob.iso8601String(), showTime: false))")
                        }
                    } else {
                        Form {
                            Text("Name:")
                            Text("Passport Number:")
                            Text("Birthdate:")
                        }
                    }

                    Button  {
                        dismiss()
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
