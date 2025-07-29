//
//  LoadingScreen.swift
//  FlightTix
//
//  Created by Jon Bauer on 11/23/24.
//

import SwiftUI
import IdentusSwift

struct LoadingScreen: View {
    
    @ObservedObject var identusStatus = IdentusStatus.shared
    
    @StateObject var model: DevUtilsModel = .init()

    var body: some View {
        ZStack {
            VStack {
                Spacer()
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
                
                Spacer()
                
                VStack {
                    Text("IdentusSwift: v\(IdentusSwift.version())")
                }
                Spacer()
            }
            .padding()
            
            
            
        }
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    LoadingScreen()
}
