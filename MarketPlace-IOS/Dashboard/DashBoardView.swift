//
//  DashBoardView.swift
//  MarketPlace-IOS
//
//  Created by karthik on 1/29/25.
//

import SwiftUI

struct DashBoardView: View {
    @StateObject var viewModel: DashBoardViewViewModel = .init()
   

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
                        viewModel.movetoSelectLocation = true
                    }) {
                        Image("pin").resizable().frame(width: 20, height: 20)
                            .foregroundColor(Color.black)
                        Text(viewModel.address?.postalCode ?? viewModel.pincode ?? "").bold().foregroundColor(.black)
                        Image("arrow-down").resizable()
                            .frame(width: 10, height: 10)
                            .foregroundColor(Color.black)
                    }
                }
          
            }.onAppear {
                UserDetails.requestLocationPermission()
                viewModel.getCurrentLocation()
            }.sheet(isPresented: $viewModel.movetoSelectLocation) {
                LocationSearchView(onAddressSelected: { address in
                    viewModel.address = address
                })
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
