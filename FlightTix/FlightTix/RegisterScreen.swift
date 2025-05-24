//
//  RegisterScreen.swift
//  FlightTix
//
//  Created by Jon Bauer on 11/9/24.
//

import SwiftUI

struct RegisterScreen: View {
    
    final class RegisterFormIncompleteError: Error {}
    
    @Environment(\.dismiss) private var dismiss
    
    @StateObject var model: RegisterViewModel = RegisterViewModel()
    
    @State private var name: String = ""
    @State private var passportNumber: String = ""
    @State private var dob = Date()
    
    @FocusState private var isFieldFocused: Bool
    
    private func onRegisterSubmit() async throws {
        
        guard name.count > 1, passportNumber.count > 1 else {
            throw RegisterFormIncompleteError()
        }
        
        do {
            // Register: Create Passport VC
            try await model.register(passport: Passport(name: name,
                                                        did: nil,
                                                        passportNumber: passportNumber,
                                                        dob: dob,
                                                        dateOfIssuance: nil))
            
            // Verify: Request Proof of valid Passport VC
            try await model.verifyCredential()
        } catch {
            throw error
        }

        // Dismiss LoginScreen
        dismiss()
    }
    
    var body: some View {
        ZStack {
            Form {
                Section("Passport Information") {
                    TextField("Name", text: $name).focused($isFieldFocused)
                    TextField("Passport Number", text: $passportNumber)
                    DatePicker(
                        "Birthdate",
                        selection: $dob,
                        displayedComponents: [.date]
                    )
                }
                
                Section {
                    Button {
                        Task {
                            try await onRegisterSubmit()
                        }
                    } label: {
                        Text("Submit")
                    }
                    
                }
            }
        }
        .onAppear {
            isFieldFocused = true
        }
    }
}

#Preview {
    RegisterScreen()
}
