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
        VStack(alignment: .leading, spacing: 24) {
            ScreenHeader(title: "Passport")
                .padding(.top)

            if !profileLoaded {
                HStack(spacing: 8) {
                    ProgressView()
                    Text("Loading passport details…").foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 40)
            } else if let traveller = model.traveller {
                VStack(spacing: 0) {
                    LabeledRow(label: "Name", value: traveller.passport.name)
                    Divider()
                    LabeledRow(label: "Passport Number", value: traveller.passport.passportNumber)
                    Divider()
                    LabeledRow(label: "Birthdate",
                               value: DateStuff.displayISODateAsString(traveller.passport.dob.iso8601String(), showTime: false))
                }
                .padding()
                .background(Color(.secondarySystemBackground),
                            in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                .padding(.horizontal)
            } else {
                Text("No passport found yet.")
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }

            Spacer()

            Button {
                dismiss()
            } label: {
                Text("Close")
            }
            .buttonStyle(.secondaryAction)
            .padding()
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
