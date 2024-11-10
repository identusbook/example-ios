//
//  SecurityView.swift
//  FlightTix
//
//  Created by Jon Bauer on 11/9/24.
//

import SwiftUI

struct SecurityView: View {
    
    private func requestProof(){}
    
    var body: some View {
        ZStack {
            VStack {
                Button  {
                    requestProof()
                } label: {
                    Text("Request Proof of Ticket")
                }
                .buttonStyle(.bordered)
            }
        }
    }
}

#Preview {
    SecurityView()
}
