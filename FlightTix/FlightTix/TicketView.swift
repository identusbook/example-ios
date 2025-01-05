//
//  TicketView.swift
//  FlightTix
//
//  Created by Jon Bauer on 11/9/24.
//

import SwiftUI

struct TicketView: View {
    
    @StateObject var model: TicketViewModel = TicketViewModel()
    let ticket: Ticket?
    
    var body: some View {
        ZStack {
            VStack {
                Text("Your Flight:")
                Text(ticket?.flight.rawValue ?? "")
                Button {
                    Task {
                        try await model.showCredentials()
                    }
                    
                } label: {
                    Text("List Tickets")
                }

            }
        }
    }
}

#Preview {
    TicketView(ticket: Ticket(flight: .ams2vie,
                              price: 500.0,
                              traveller: Traveller(passport: Passport(name: "Jon Bauer",
                                                                      did: "123456789",
                                                                      passportNumber: "123456789",
                                                                      dob: Date(),
                                                                      dateOfIssuance: Date())
                              )))
}
