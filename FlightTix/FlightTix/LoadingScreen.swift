//
//  LoadingScreen.swift
//  FlightTix
//
//  Created by Jon Bauer on 11/23/24.
//

import SwiftUI

struct LoadingScreen: View {
    var body: some View {
        ZStack {
            VStack {
                Text("FlightTxt")
                    .font(.largeTitle)
                Text("powered by")
                    .font(.callout)
                Image(.identusLogo)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaledToFit()
                    .frame(width: 200)
            }
            .padding()
        }
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    LoadingScreen()
}
