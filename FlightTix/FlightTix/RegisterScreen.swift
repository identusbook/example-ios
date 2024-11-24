//
//  RegisterScreen.swift
//  FlightTix
//
//  Created by Jon Bauer on 11/9/24.
//

import SwiftUI

struct RegisterScreen: View {
    
    @Environment(\.dismiss) private var dismiss
    
    private func onRegisterSubmit(){
        // Save Passport info in keychain
        // Request Airline to Issue a Login VC
        // Wait for Issuance
        // Dismiss LoginScreen
        print("Handle Registration / Login VC Issuance here")
        dismiss()
    }
    
    @State var showChoices: Bool = true
    @State var showRegisterForm: Bool = false
    
    @State private var name: String = ""
    @State private var passportNumber: String = ""
    @State private var date = Date()
    
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
                            onRegisterSubmit()
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
