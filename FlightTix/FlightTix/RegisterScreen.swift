//
//  RegisterScreen.swift
//  FlightTix
//
//  Created by Jon Bauer on 11/9/24.
//

import SwiftUI

struct RegisterScreen: View {
    
    final class RegisterFormIncompleteError: Error {}
    final class RegisterFormRegisterError: Error {}
    final class RegisterFormVerifyCredentialError: Error {}
    
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
        } catch {
            print(error)
            throw RegisterFormRegisterError()
        }
        
        // Wait 60 seconds for for Credential dance before trying to verify
        try await Task.sleep(nanoseconds: 60_000_000_000)
        
        do {
            // Verify: Request Proof of valid Passport VC
            let presentation = try await model.requestProof()
            print("PRESENTATION REQUEST IS: \(presentation)")
            
            try await Task.sleep(nanoseconds: 30_000_000_000)
            
            // Dismiss LoginScreen after Proof flow is complete
            dismiss()
        } catch {
            print(error)
            throw RegisterFormVerifyCredentialError()
        }
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
