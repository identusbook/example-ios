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
    
    @State var showChoices: Bool = true
    @State var showRegisterForm: Bool = false
    
    @State private var name: String = ""
    @State private var passportNumber: String = ""
    @State private var date = Date()
    
    private func onRegisterSubmit() async throws {
        
        guard name.count > 1, passportNumber.count > 1 else {
            throw RegisterFormIncompleteError()
        }
        
        do {
            try await model.register(passport: Passport(name: name,
                                                        passportNumber: passportNumber,
                                                        dob: Date(),
                                                        dateOfIssuance: Date()))
        } catch {
            throw error
        }
        
        // Dismiss LoginScreen
        dismiss()
    }
    
    var body: some View {
        ZStack {
            if showRegisterForm {
                Form {
                    Section("Passport Information") {
                        TextField("Name", text: $name)
                        TextField("Passport Number", text: $passportNumber)
                        DatePicker(
                            "Birthdate",
                            selection: $date,
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
            
            if showChoices {
                VStack {
                    Button {
                        showRegisterForm = true
                        showChoices = false
                    } label: {
                        Text("Create Account")
                    }
                }
            }
            
        }
        .onAppear {
            //if !passportVCExists() {
                showChoices = true
                showRegisterForm = false
            //}
        }
        
    }
}

#Preview {
    RegisterScreen()
}
