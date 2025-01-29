//
//  DashBoardView.swift
//  MarketPlace-IOS
//
//  Created by karthik on 1/29/25.
//

import SwiftUI

struct DashBoardView: View {
    var body: some View {
        NavigationStack {
            Text("Hello, World!")
        }.navigationTitle("Products")
            .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) { // Add a button on the right side
                        Button(action: {
                            // Action to add a product
                        }) {
                            Image(systemName: "plus")
                                .foregroundColor(Color.themeRed)
                        }
                    }
                    
                }
    }
}

#Preview {
    DashBoardView()
}
