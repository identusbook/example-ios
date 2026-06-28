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
        
        // Wait 20 seconds for for Credential dance before trying to verify
        try await Task.sleep(nanoseconds: 20_000_000_000)
        
        // Verify: Request Proof of valid Passport VC
        let presentation = try await model.requestProof()
        //print("PRESENTATION REQUEST IS: \(presentation)")
        
        // Dismiss LoginScreen after Proof flow is complete
        dismiss()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScreenHeader(title: "Create Passport",
                         subtitle: "We'll issue a passport credential to your wallet.")
                .padding(.top)

            if !model.isIssuerReady {
                HStack(spacing: 8) {
                    ProgressView()
                    Text("Preparing issuer… the form will enable once it's ready.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top, 8)
            }

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
            }
            .disabled(!model.isIssuerReady)

            VStack(spacing: 12) {
                AsyncButton("Submit") {
                    do {
                        try await onRegisterSubmit()
                    } catch {
                        print("Register submit failed: \(error)")
                    }
                }
                .buttonStyle(.primary)
                .disabled(!model.isIssuerReady)

                Button {
                    dismiss()
                } label: {
                    Text("Close")
                }
                .buttonStyle(.secondaryAction)
            }
            .padding()
        }
        .task {
            // Gate the form on the issuer DID being published (issuance depends on it).
            await model.confirmIssuerReady()
        }
        .onAppear {
            isFieldFocused = true
        }
    }
}

#Preview {
    RegisterScreen()
}
