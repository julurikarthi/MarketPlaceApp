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
    
    init() {
            GMSPlacesClient.provideAPIKey("AIzaSyCilh2e-XLRrdwSM0hHfcGMewbYbZfcmHU")
        }
    
    var body: some Scene {
        WindowGroup {
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
                DashboardView()
            }
        }
    }
}



extension View {
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
