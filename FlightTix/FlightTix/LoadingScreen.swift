//
//  LoadingScreen.swift
//  FlightTix
//
//  Created by Jon Bauer on 11/23/24.
//

import SwiftUI

struct LoadingScreen: View {
    
    @ObservedObject var identusStatus = IdentusStatus.shared
    
    @StateObject var model: DevUtilsModel = .init()

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
                    .padding(.bottom, 40)
                ProgressView(String(identusStatus.status.description))
                
                
                Button {
                    Task {
                        try await model.tearDown()
                        try await model.stop()
                    }
                } label: {
                    Text("Tear Down and Stop")
                }
                .buttonStyle(.bordered)

            }
            .padding()
            
            
            
        }
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    LoadingScreen()
}
