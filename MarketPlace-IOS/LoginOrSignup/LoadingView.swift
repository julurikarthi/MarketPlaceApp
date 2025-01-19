//
//  LoadingView.swift
//  MarketPlace-IOS
//
//  Created by karthik on 1/19/25.
//
import SwiftUI
struct LoadingView: View {
    var body: some View {
        ZStack {
            Image("welcome")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
        }
    }
}
