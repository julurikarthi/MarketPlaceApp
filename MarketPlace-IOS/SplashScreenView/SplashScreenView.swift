//
//  SplashScreenView.swift
//  MarketPlace-IOS
//
//  Created by karthik on 2/12/25.
//
import SwiftUI
struct SplashScreenView: View {
    var body: some View {
        VStack {
            Image("welcomescreen")
                .resizable()
                .scaledToFit()
                .frame(width: .infinity, height: .infinity)
        }
    }
}

#Preview {
    SplashScreenView()
}
