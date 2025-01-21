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
            HomeView()
                   .tabItem {
                       Image(selectedTab == 0 ? "homeselected" : "home").resizable()
                       Text("Home")
                   }.tag(0)

            SearchView()
                .tabItem {
                    Image(selectedTab == 1 ? "categoryselected" : "category-1")
                    Text("Search")
                }.tag(1)
            
            ProfileView()
                .tabItem {
                    Image(selectedTab == 2 ? "orderselected" : "orders")
                    Text("Profile")
                }.tag(2)

            ProfileView()
                .tabItem {
                    Image(selectedTab == 3 ? "profileselected" : "profile")
                    Text("Profile")
                }.tag(3)
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
