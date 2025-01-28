//
//  HomePage.swift
//  MarketPlace-IOS
//
//  Created by karthik on 1/21/25.
//

import SwiftUI

struct HomePage: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            ProductListView()
                   .tabItem {
                       Image(selectedTab == 0 ? "homeselected" : "home").resizable()
                       Text("Home")
                   }.tag(0)

            ProfileView()
                .tabItem {
                    Image(selectedTab == 2 ? "orderselected" : "orders")
                    Text("Profile")
                }.tag(1)

            ProfileView()
                .tabItem {
                    Image(selectedTab == 3 ? "profileselected" : "profile")
                    Text("Profile")
                }.tag(2)
        }
        .accentColor(.red) // Change active tab color
    }
}

struct HomeView: View {
    var body: some View {
        Text("Home Screen")
    }
}

struct SearchView: View {
    var body: some View {
        Text("Search Screen")
    }
}

struct ProfileView: View {
    var body: some View {
        Text("Profile Screen")
    }
}


#Preview {
    HomePage()
}
