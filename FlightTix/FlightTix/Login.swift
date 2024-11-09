//
//  Login.swift
//  FlightTix
//
//  Created by Jon Bauer on 11/9/24.
//

import SwiftUI

struct Login: View {
    
    private func login(){}
    
    var body: some View {
        ZStack {
            VStack {
                
                Button {
                    login()
                } label: {
                    Text("Login")
                }
            }
        }
        
    }
}

#Preview {
    Login()
}
