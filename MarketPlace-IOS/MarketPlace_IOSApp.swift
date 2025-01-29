//
//  MarketPlace_IOSApp.swift
//  MarketPlace-IOS
//
//  Created by karthik on 1/19/25.
//

import SwiftUI

@main
struct MarketPlace_IOSApp: App {
    var body: some Scene {
        WindowGroup {
            if UserDetails.isAppOwners {
                if UserDetails.isLoggedIn {
                    // If the user is logged in, show the HomePage
                    HomePage()
                } else {
                    // If the user is not logged in, show the LoginView
                    LoginView()
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
