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
    
    private func onRegisterSubmit() async throws {
        
        guard name.count > 1, passportNumber.count > 1 else {
            throw RegisterFormIncompleteError()
        }
        
        do {
            try await model.register(passport: Passport(name: name,
                                                        did: nil,
                                                        passportNumber: passportNumber,
                                                        dob: dob,
                                                        dateOfIssuance: nil))
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
                    TextField("Name", text: $name)
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
    }
}

#Preview {
    RegisterScreen()
}
