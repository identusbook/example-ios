//
//  TicketView.swift
//  FlightTix
//
//  Created by Jon Bauer on 11/9/24.
//

import SwiftUI

struct TicketView: View {
    var body: some View {
        ZStack {
            VStack {
                Text("Your Flight:")
                Text(Flights.atl2scl.rawValue)
            }
        }
    }
}

#Preview {
    TicketView()
}
