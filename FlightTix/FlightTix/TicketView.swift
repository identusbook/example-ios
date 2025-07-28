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
    
    var valueFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    func formattedPrice(_ price: Double) -> String {
        return valueFormatter.string(from: NSNumber(value: price)) ?? ""
    }
    
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
                        Text("Price: \(formattedPrice(model.ticket!.price))")
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
