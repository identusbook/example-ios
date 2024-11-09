//
//  Profile.swift
//  FlightTix
//
//  Created by Jon Bauer on 11/9/24.
//

import SwiftUI

struct Profile: View {
    
    @Environment(\.dismiss) private var dismiss
    
    private func logout() {
        dismiss()
    }
    
    var body: some View {
        ZStack {
            VStack {
                Text("Profile")
                
                Form {
                    Text("DID: ")
                }
                
                Button  {
                    logout()
                } label: {
                    Text("Logout")
                }
                
                Spacer()
            }
        }
    }
}

#Preview {
    Profile()
}
