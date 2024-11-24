//
//  TicketTab.swift
//  FlightTix
//
//  Created by Jon Bauer on 11/17/24.
//

import SwiftUI

struct TicketTab: View {
    @State var ticket: Ticket?
    var body: some View {
        TicketView(ticket: ticket)
    }
}

#Preview {
    TicketTab()
}
