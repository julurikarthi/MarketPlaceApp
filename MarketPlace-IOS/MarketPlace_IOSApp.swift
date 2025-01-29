//
//  MarketPlace_IOSApp.swift
//  MarketPlace-IOS
//
//  Created by karthik on 1/19/25.
//

import SwiftUI
//import GooglePlaces

@main
struct MarketPlace_IOSApp: App {
    var body: some Scene {
        WindowGroup {
            if UserDetails.isAppOwners {
                LocationSearchView()
//                if UserDetails.isLoggedIn {
//                    HomePage()
//                } else {
//                    LoginView()
//                }
            }
        }
    }
}



extension View {
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
