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
        VStack(alignment: .leading, spacing: 24) {
            ScreenHeader(title: "Your Ticket")
                .padding(.top)

            if !ticketLoaded {
                HStack(spacing: 8) {
                    ProgressView()
                    Text("Loading ticket details…").foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 40)
            } else if let ticket = model.ticket {
                VStack(spacing: 0) {
                    LabeledRow(label: "Departure", value: ticket.departure)
                    Divider()
                    LabeledRow(label: "Arrival", value: ticket.arrival)
                    Divider()
                    LabeledRow(label: "Price", value: formattedPrice(ticket.price))
                }
                .padding()
                .background(Color(.secondarySystemBackground),
                            in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                .padding(.horizontal)
            } else {
                Text("No ticket found yet. Purchase a flight to receive one.")
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }

            Spacer()
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
