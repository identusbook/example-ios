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
    
    @State private var ticketLoaded: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                if !ticketLoaded {
                    Text("Loading Ticket Details...")
                } else {
                    VStack {
                        Text("Your Ticket Details:")
                        Text("Departure: \(model.ticket?.departure ?? "")")
                        Text("Arrival: \(model.ticket?.arrival ?? "")")
                        Text("Price: \(model.ticket?.price ?? 0.0)")
                    }
                }
            }
        }
        .onAppear() {
            // Check for Ticket VC
            // Load data from Ticket VC
            Task {
                try await model.getTicket()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    ticketLoaded = true
                }
            }
        }
    }
}

//#Preview {
//    TicketView(ticket: Ticket(flight: .ams2vie,
//                              price: 500.0,
//                              traveller: Traveller(passport: Passport(name: "Jon Bauer",
//                                                                      did: "123456789",
//                                                                      passportNumber: "123456789",
//                                                                      dob: Date(),
//                                                                      dateOfIssuance: Date())
//                              )))
//}
