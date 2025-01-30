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
            VStack {
                SearchBarView()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    // Add a button on the right side
                    Button(action: {
                        // Action to add a product
                    }) {
                        Image("shopping-cart").resizable().frame(width: 20, height: 20).padding(.trailing, 4)
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    // Add a button on the right side
                    Button(action: {
                        // Action to add a product
                    }) {
                        Image("pin").resizable().frame(width: 20, height: 20)
                            .foregroundColor(Color.black)
                        Text("1231 Lilles Way").bold().foregroundColor(.black)
                        Image("arrow-down").resizable()
                            .frame(width: 10, height: 10)
                            .foregroundColor(Color.black)
                    }
                }
            }.onAppear {
                UserDetails.requestLocationPermission()
            }
        }.tint(.black)
    }
}

#Preview {
    DashBoardView()
}
struct SearchBarView: View {
    @State private var searchText = ""
    @State private var isSearching = false

    var body: some View {
        NavigationStack {
            VStack {
            }
            .searchable(
                text: $searchText,
                isPresented: $isSearching,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search products"
            )
        }
    }
}
