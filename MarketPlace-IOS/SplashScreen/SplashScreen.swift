//
//  SplashScreen.swift
//  MarketPlace-IOS
//
//  Created by karthik on 1/27/25.
//

import SwiftUI

struct SplashScreen: View {
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Image("welcomescreen")
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width, height: geometry.size.height)
            }
            .background(Color(hex: "#D7D7D2"))
        }
    }
}

#Preview {
    SplashScreen()
}
