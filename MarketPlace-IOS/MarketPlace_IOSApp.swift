//
//  MarketPlace_IOSApp.swift
//  MarketPlace-IOS
//
//  Created by karthik on 1/19/25.
//

import SwiftUI
import GooglePlaces

@main
struct MarketPlace_IOSApp: App {
    @StateObject var cartViewModel = CartViewModel()

    init() {
            GMSPlacesClient.provideAPIKey("AIzaSyCilh2e-XLRrdwSM0hHfcGMewbYbZfcmHU")
        }
    
    var body: some Scene {
            WindowGroup {
                ZStack {
                    Color.white.edgesIgnoringSafeArea(.all) // Apply global background
                    
                    if UserDetails.isAppOwners {
                        if UserDetails.isLoggedIn {
                            if UserDetails.storeId != nil {
                                HomePage()
                            } else {
                                CreateStoreView()
                            }
                        } else {
                            LoginView()
                        }
                    } else {
                        DashboardView().environmentObject(cartViewModel)
                    }
                }.globalBackground(.white).onAppear {
                    if UserDetails.isAppOwners {
                        UserDetails.userType = .storeOwner
                    } else {
                        UserDetails.userType = .customer
                    }
                }
            }
        }
}



extension View {
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}


struct CartNavigationView<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            
                        }) {
                            Image("shopping-cart").resizable().frame(width: 20, height: 20).padding(.trailing, 4)
                        }
                        .frame(height: 200)
                        .cornerRadius(10)
                        .clipped()
                    }
                }
        }
    }
}
