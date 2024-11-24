//
//  TicketView.swift
//  FlightTix
//
//  Created by Jon Bauer on 11/9/24.
//

import SwiftUI

struct TicketView: View {
    
    let ticket: Ticket?
    
    var body: some View {
        ZStack {
            VStack {
                Text("Your Flight:")
                Text(ticket?.flight.rawValue ?? "")
            }
        }
    }
}

#Preview {
    TicketView(ticket: Ticket(flight: .ams2vie,
                              price: 500.0,
                              traveller: Traveller(name: "Jon Bauer",
                                                   did: "123456789",
                                                   passportNumber: "123098",
                                                   dob: Date())))
}
